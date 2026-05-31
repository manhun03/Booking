# AIAgent Chat Backend API

AIAgent la FastAPI service dung de chay AI chat cho he thong dat phong khach san.

Flow hien tai:

```text
Flutter/Client
  -> Java Backend: http://localhost:8080/api/ai-chat
  -> AIAgent:      http://localhost:8000
  -> Groq model
```

Frontend nen goi qua Java Backend `/api/ai-chat`. Khong nen goi truc tiep AIAgent tu FE, vi Java Backend da proxy Authorization header va gom tat ca API ve mot backend chinh.

## File Chinh

- `chat_backend.py`: khoi tao FastAPI app, CORS, startup DB, include router.
- `chat_controller.py`: khai bao endpoint FastAPI va DTO request/response.
- `chat_service.py`: nghiep vu chat, SQLite memory, thread/message, goi AI Agent.
- `auth_jwt.py`: doc JWT tu `Authorization: Bearer <accessToken>` va lay `user_id`.
- `agent2.py`: cau hinh LangChain/Groq agent, tools, memory/checkpoint.
- `call_api.py`: tool goi Java Backend de tim hotel/room.
- `.env`: chua `GROQ_API_KEY` va URL backend. File nay da nam trong `.gitignore`.

## Cau Hinh

File `.env` trong thu muc `AIAgent`:

```env
GROQ_API_KEY=your-groq-api-key
AUTH_API_BASE_URL=http://localhost:8080/api/auth
TRAVEL_API_BASE_URL=http://localhost:8080/api
```

Khong commit file `.env` len GitHub.

Mac dinh trong code:

```text
AUTH_API_BASE_URL=http://localhost:8080/api/auth
TRAVEL_API_BASE_URL=http://localhost:8080/api
```

## Chay AIAgent

Mo `cmd` hoac PowerShell:

```powershell
cd F:\Downloads\AI-integrated-hotel-booking-app-main\AI-integrated-hotel-booking-app-main\AIAgent
.\.venv\Scripts\python.exe -m uvicorn chat_backend:app --host 0.0.0.0 --port 8000
```

Neu dung PowerShell va muon activate venv:

```powershell
cd F:\Downloads\AI-integrated-hotel-booking-app-main\AI-integrated-hotel-booking-app-main\AIAgent
.\.venv\Scripts\activate
uvicorn chat_backend:app --host 0.0.0.0 --port 8000
```

Neu bao loi port 8000 dang duoc su dung:

```powershell
$p = (Get-NetTCPConnection -LocalPort 8000 -State Listen).OwningProcess
Stop-Process -Id $p -Force
```

Sau do chay lai AIAgent.

## Kiem Tra AIAgent

Neu dang dung `cmd`:

```cmd
curl http://localhost:8000/health
```

Neu dang dung PowerShell:

```powershell
Invoke-RestMethod http://localhost:8000/health
```

Ket qua dung:

```json
{"status":"ok"}
```

Swagger cua AIAgent:

```text
http://localhost:8000/docs
```

ReDoc:

```text
http://localhost:8000/redoc
```

OpenAPI JSON:

```text
http://localhost:8000/openapi.json
```

## Java Backend Proxy

Java Backend da noi voi AIAgent qua:

```text
http://localhost:8080/api/ai-chat
```

Cau hinh trong Java Backend:

```yaml
app:
  ai-agent:
    base-url: ${AI_AGENT_BASE_URL:http://localhost:8000}
```

Neu AIAgent chay o URL khac:

```powershell
$env:AI_AGENT_BASE_URL="http://localhost:8000"
```

Sau do restart Java Backend.

## Kiem Tra Proxy Qua Java Backend

Dung `cmd`:

```cmd
curl http://localhost:8080/api/ai-chat/health
```

Dung PowerShell:

```powershell
Invoke-RestMethod http://localhost:8080/api/ai-chat/health
```

Ket qua dung:

```json
{"status":"ok"}
```

Swagger cua Java Backend:

```text
http://localhost:8080/swagger-ui/index.html
```

Trong Swagger Java, tim controller:

```text
ai-chat-controller
```

## Endpoints AIAgent Goc

Neu can test truc tiep AIAgent:

```http
GET    /health
POST   /threads
GET    /threads
GET    /threads/{thread_id}
DELETE /threads/{thread_id}
GET    /threads/{thread_id}/messages
POST   /threads/{thread_id}/messages
POST   /chat
```

Tat ca endpoint thread/message can header:

```http
Authorization: Bearer <accessToken>
```

Token lay tu Java Backend:

```http
POST http://localhost:8080/api/auth/login
```

## Endpoints Nen Dung Qua Java Backend

Frontend nen dung cac endpoint nay:

```http
GET    /api/ai-chat/health
POST   /api/ai-chat/threads
GET    /api/ai-chat/threads
GET    /api/ai-chat/threads/{threadId}
DELETE /api/ai-chat/threads/{threadId}
GET    /api/ai-chat/threads/{threadId}/messages
POST   /api/ai-chat/threads/{threadId}/messages
POST   /api/ai-chat/chat
```

## Tao Thread

```http
POST http://localhost:8080/api/ai-chat/threads
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "title": "Tim khach san Da Nang"
}
```

Response:

```json
{
  "thread_id": "2d4b25f4-6f15-4f30-9877-7ef31b6e5949",
  "title": "Tim khach san Da Nang",
  "user_id": "19",
  "created_at": "2026-05-24T08:00:00+00:00",
  "updated_at": "2026-05-24T08:00:00+00:00"
}
```

## Gui Message

```http
POST http://localhost:8080/api/ai-chat/threads/{threadId}/messages
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "message": "Tim giup toi khach san o Da Nang"
}
```

Response:

```json
{
  "thread_id": "2d4b25f4-6f15-4f30-9877-7ef31b6e5949",
  "message": {
    "id": 2,
    "thread_id": "2d4b25f4-6f15-4f30-9877-7ef31b6e5949",
    "role": "assistant",
    "content": "Noi dung AI tra loi...",
    "created_at": "2026-05-24T08:01:00+00:00"
  }
}
```

Endpoint thay the:

```http
POST http://localhost:8080/api/ai-chat/chat
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "thread_id": "2d4b25f4-6f15-4f30-9877-7ef31b6e5949",
  "message": "Tim giup toi khach san o Da Nang"
}
```

## Lay Lich Su Message

```http
GET http://localhost:8080/api/ai-chat/threads/{threadId}/messages
Authorization: Bearer <accessToken>
```

## Xoa Thread

```http
DELETE http://localhost:8080/api/ai-chat/threads/{threadId}
Authorization: Bearer <accessToken>
```

Xoa thread se xoa:

- metadata trong `chat_threads`
- message log trong `chat_messages`
- checkpoint memory cua LangGraph theo `thread_id`

## Vi Du Frontend Fetch

```ts
const apiBase = "http://localhost:8080/api/ai-chat";

export async function createThread(accessToken: string, title?: string) {
  const res = await fetch(`${apiBase}/threads`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({ title }),
  });
  return res.json();
}

export async function sendMessage(
  accessToken: string,
  threadId: string,
  message: string,
) {
  const res = await fetch(`${apiBase}/threads/${threadId}/messages`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({ message }),
  });
  return res.json();
}

export async function listMessages(accessToken: string, threadId: string) {
  const res = await fetch(`${apiBase}/threads/${threadId}/messages`, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });
  return res.json();
}

export async function deleteThread(accessToken: string, threadId: string) {
  await fetch(`${apiBase}/threads/${threadId}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });
}
```

## Loi Thuong Gap

### Port 8000 bi trung

Loi:

```text
ERROR: [Errno 10048] only one usage of each socket address is normally permitted
```

Xu ly:

```powershell
$p = (Get-NetTCPConnection -LocalPort 8000 -State Listen).OwningProcess
Stop-Process -Id $p -Force
```

### `Invoke-RestMethod` khong nhan

Ban dang dung `cmd`. Hay dung:

```cmd
curl http://localhost:8000/health
```

Hoac mo PowerShell de dung:

```powershell
Invoke-RestMethod http://localhost:8000/health
```

### Thieu GROQ_API_KEY

Loi:

```text
The api_key client option must be set
```

Them vao `AIAgent\.env`:

```env
GROQ_API_KEY=your-groq-api-key
```

Sau do restart AIAgent.

### Java proxy khong goi duoc AIAgent

Kiem tra AIAgent:

```cmd
curl http://localhost:8000/health
```

Kiem tra proxy Java:

```cmd
curl http://localhost:8080/api/ai-chat/health
```
