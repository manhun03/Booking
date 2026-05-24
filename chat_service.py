import os
import sqlite3
import uuid
from contextlib import contextmanager
from datetime import datetime, timezone
from urllib.parse import urljoin

import requests
from fastapi import HTTPException, status

from agent2 import chat as agent_chat


DB_PATH = "memory.db"
AUTH_API_BASE_URL = os.getenv("AUTH_API_BASE_URL", "http://localhost:5146/api/auth")


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


@contextmanager
def db_connection():
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;")
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_chat_db() -> None:
    with db_connection() as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS chat_threads (
                thread_id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                user_id TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """
        )
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS chat_messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                thread_id TEXT NOT NULL,
                role TEXT NOT NULL CHECK(role IN ('user', 'assistant')),
                content TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY(thread_id) REFERENCES chat_threads(thread_id)
                    ON DELETE CASCADE
            )
            """
        )
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_id ON chat_messages(thread_id)"
        )


def ensure_thread_belongs_to_user(
    conn: sqlite3.Connection,
    thread_id: str,
    user_id: str,
) -> None:
    thread = conn.execute(
        "SELECT thread_id FROM chat_threads WHERE thread_id = ? AND user_id = ?",
        (thread_id, user_id),
    ).fetchone()
    if not thread:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Thread khong ton tai hoac khong thuoc user hien tai.",
        )


def delete_agent_thread_memory(conn: sqlite3.Connection, thread_id: str) -> None:
    for table in ("checkpoint_writes", "checkpoint_blobs", "checkpoints", "writes"):
        columns = {
            row["name"]
            for row in conn.execute(f"PRAGMA table_info({table})").fetchall()
        }
        if "thread_id" in columns:
            conn.execute(f"DELETE FROM {table} WHERE thread_id = ?", (thread_id,))


def post_auth_api(endpoint: str, payload: dict) -> dict:
    url = urljoin(AUTH_API_BASE_URL.rstrip("/") + "/", endpoint.lstrip("/"))
    try:
        response = requests.post(url, json=payload, timeout=15)
        response.raise_for_status()
    except requests.RequestException as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Khong goi duoc Auth API {url}: {exc}",
        ) from exc

    try:
        return response.json()
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Auth API tra ve response khong phai JSON.",
        ) from exc


def create_thread(title: str | None, user_id: str) -> dict:
    now = utc_now()
    thread_id = str(uuid.uuid4())
    thread_title = title.strip() if title else "Hoi thoai moi"

    with db_connection() as conn:
        conn.execute(
            """
            INSERT INTO chat_threads (thread_id, title, user_id, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (thread_id, thread_title, user_id, now, now),
        )

    return {
        "thread_id": thread_id,
        "title": thread_title,
        "user_id": user_id,
        "created_at": now,
        "updated_at": now,
    }


def list_threads(user_id: str) -> list[dict]:
    with db_connection() as conn:
        rows = conn.execute(
            """
            SELECT thread_id, title, user_id, created_at, updated_at
            FROM chat_threads
            WHERE user_id = ?
            ORDER BY updated_at DESC
            """,
            (user_id,),
        ).fetchall()

    return [dict(row) for row in rows]


def get_thread(thread_id: str, user_id: str) -> dict:
    with db_connection() as conn:
        row = conn.execute(
            """
            SELECT thread_id, title, user_id, created_at, updated_at
            FROM chat_threads
            WHERE thread_id = ? AND user_id = ?
            """,
            (thread_id, user_id),
        ).fetchone()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Thread khong ton tai.",
        )

    return dict(row)


def delete_thread(thread_id: str, user_id: str) -> None:
    with db_connection() as conn:
        ensure_thread_belongs_to_user(conn, thread_id, user_id)
        conn.execute("DELETE FROM chat_messages WHERE thread_id = ?", (thread_id,))
        conn.execute("DELETE FROM chat_threads WHERE thread_id = ?", (thread_id,))
        delete_agent_thread_memory(conn, thread_id)


def list_messages(thread_id: str, user_id: str) -> list[dict]:
    with db_connection() as conn:
        ensure_thread_belongs_to_user(conn, thread_id, user_id)
        rows = conn.execute(
            """
            SELECT id, thread_id, role, content, created_at
            FROM chat_messages
            WHERE thread_id = ?
            ORDER BY id ASC
            """,
            (thread_id,),
        ).fetchall()

    return [dict(row) for row in rows]


def send_message(thread_id: str, message: str, user_id: str) -> dict:
    user_message = message.strip()
    if not user_message:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Message khong duoc rong.",
        )

    with db_connection() as conn:
        ensure_thread_belongs_to_user(conn, thread_id, user_id)
        now = utc_now()
        conn.execute(
            """
            INSERT INTO chat_messages (thread_id, role, content, created_at)
            VALUES (?, 'user', ?, ?)
            """,
            (thread_id, user_message, now),
        )
        conn.execute(
            "UPDATE chat_threads SET updated_at = ? WHERE thread_id = ?",
            (now, thread_id),
        )

    try:
        ai_reply = agent_chat(thread_id, user_message)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"AI Agent loi: {exc}",
        ) from exc

    with db_connection() as conn:
        now = utc_now()
        cursor = conn.execute(
            """
            INSERT INTO chat_messages (thread_id, role, content, created_at)
            VALUES (?, 'assistant', ?, ?)
            """,
            (thread_id, ai_reply, now),
        )
        conn.execute(
            "UPDATE chat_threads SET updated_at = ? WHERE thread_id = ?",
            (now, thread_id),
        )
        message_id = cursor.lastrowid

    return {
        "thread_id": thread_id,
        "message": {
            "id": message_id,
            "thread_id": thread_id,
            "role": "assistant",
            "content": ai_reply,
            "created_at": now,
        },
    }
