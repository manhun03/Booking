import sqlite3
from typing import Dict, Any, Set
from langchain_groq import ChatGroq
from langchain.agents import create_agent, AgentState
from langchain.agents.middleware import wrap_tool_call, wrap_model_call
from langchain.messages import HumanMessage, ToolMessage
from dotenv import load_dotenv
from langgraph.checkpoint.sqlite import SqliteSaver
load_dotenv()

# =========================
# 1. CUSTOM STATE
# =========================
class CustomState(AgentState):
    user_preferences: Dict[str, Any] = {}
    summary: str = ""


# =========================
# 2. SQLITE + WAL
# =========================
def init_db():
    conn = sqlite3.connect("memory.db", check_same_thread=False)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.commit()
    return conn

conn = init_db()
checkpointer = SqliteSaver(conn)


# =========================
# 3. LOAD SYSTEM PROMPT
# =========================
def load_system_prompt():
    with open("Promt.txt", "r", encoding="utf-8") as f:
        return f.read()

SYSTEM_PROMPT = load_system_prompt()


# =========================
# 4. IMPORT TOOLS
# =========================
from testapi import (
    search_hotels,
    search_hotelsbyname,
    search_hotelsbyprovince,
    search_roomtypebyHotelID
)

TOOLS = [
    search_hotels,
    search_hotelsbyname,
    search_hotelsbyprovince,
    search_roomtypebyHotelID
]

ALLOWED_TOOLS: Set[str] = {t.name for t in TOOLS}


# =========================
# 5. MIDDLEWARES
# =========================

# ---- TOOL VALIDATOR + ERROR HANDLER ----
@wrap_tool_call
def tool_guard(request, handler):
    tool_name = request.tool_call["name"]

    # Validate tool
    if tool_name not in ALLOWED_TOOLS:
        return ToolMessage(
            content=f"Tool '{tool_name}' không hợp lệ. Hãy chọn tool đúng.",
            tool_call_id=request.tool_call["id"]
        )

    # Handle runtime error
    try:
        return handler(request)
    except Exception as e:
        return ToolMessage(
            content=f"Tool error: {str(e)}",
            tool_call_id=request.tool_call["id"]
        )

from langchain.messages import HumanMessage, AIMessage

@wrap_model_call
def summarization_middleware(request, handler):
    messages = request.messages
    state = request.state

    # Đếm số câu hỏi thực tế
    human_messages = [m for m in messages if isinstance(m, HumanMessage)]
    count_human = len(human_messages)

    # Chỉ summarize khi đủ 5 câu hỏi
    if count_human == 0 or count_human % 5 != 0:
        return handler(request)

    # Tránh summarize giữa chừng (phải là sau khi AI trả lời)
    if not isinstance(messages[-1], AIMessage):
        return handler(request)

    print(f"\n--- ĐANG TÓM TẮT ({count_human}) ---")

    llm = request.model
    old_summary = state.get("summary", "")

    # Lấy context gần nhất
    recent_context = messages[-10:]

    prompt = f"""
    Tóm tắt trước đó:
    {old_summary}

    Hội thoại gần nhất:
    {recent_context}

    Hãy tạo bản tóm tắt ngắn gọn, giữ thông tin quan trọng.
    """

    try:
        summary = llm.invoke(prompt).content

        # Lưu summary
        state["summary"] = summary

        # Giữ lại 2 message gần nhất
        request = request.override(messages=messages[-2:])

    except Exception as e:
        print("Summarize error:", e)

    return handler(request)

# =========================
# 6. LLM
# =========================
llm = ChatGroq(
    model="openai/gpt-oss-120b",
    temperature=0
)


# =========================
# 7. CREATE AGENT
# =========================
agent = create_agent(
    model=llm,
    tools=TOOLS,
    system_prompt=SYSTEM_PROMPT,
    middleware=[
        tool_guard,
        summarization_middleware
    ],
    checkpointer=checkpointer,
    state_schema=CustomState
)


# =========================
# 8. CHAT FUNCTION
# =========================
def chat(thread_id: str, message: str):
    result = agent.invoke(
        {
            "messages": [HumanMessage(content=message)]
        },
        config={
            "configurable": {
                "thread_id": thread_id
            }
        }
    )
    ai_reply = result["messages"][-1].content

    return ai_reply

if __name__ == "__main__":
    print("=== Local Chat Test ===")

    thread_id = input("thread ID: ").strip()

    while True:
        msg = input("User: ")

        if msg.lower() in ["exit", "quit"]:
            break

        ai_reply = chat(thread_id, msg)
        print("AI:", ai_reply)
        
        