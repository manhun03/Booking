# Chat Backend API

Backend duoc chia theo cac file:

- `chat_backend.py`: khoi tao FastAPI app, CORS, startup DB, include router.
- `chat_controller.py`: controller/router, dinh nghia endpoint va request/response DTO.
- `chat_service.py`: nghiep vu chat, DB, forward Auth API ASP.NET, goi AI Agent.
- `auth_jwt.py`: doc JWT tu `Authorization: Bearer <accessToken>` va lay `user_id`.

## Chay server

```powershell
pip install -e .
uvicorn chat_backend:app --reload --host 0.0.0.0 --port 8000
```

Neu dang dung virtualenv cua project:

```powershell
.venv\Scripts\activate
pip install -e .
uvicorn chat_backend:app --reload --port 8000
```

Mac dinh backend chat se goi Auth API ASP.NET tai:

```text
http://localhost:5146/api/auth
```

Neu URL khac, set bien moi truong:

```powershell
$env:AUTH_API_BASE_URL="http://localhost:5146/api/auth"
```

## Flow cho frontend

1. Login/register bang ASP.NET Auth API hoac proxy cua chat backend.
2. Luu `thread_id` tra ve o state frontend.
3. Khi goi chat backend, gui header `Authorization: Bearer <accessToken>`.
4. Tao hoi thoai moi bang `POST /threads`.
5. Khi user gui tin nhan, goi `POST /threads/{thread_id}/messages`.
6. Khi user bam xoa hoi thoai, goi `DELETE /threads/{thread_id}`.
7. Neu can hien lai lich su, goi `GET /threads/{thread_id}/messages`.

Backend chat se tu doc `user_id` tu JWT claim, frontend khong can truyen `user_id`.
Swagger cua `chat_backend` tai `/docs` co nut `Authorize`; nhap token theo dang `Bearer <accessToken>`.

## Endpoints

### Auth proxy

Neu frontend muon goi tat ca qua chat backend:

```http
POST /auth/register
POST /auth/login
POST /auth/refresh-token
```

Ba endpoint nay forward request sang ASP.NET:

```text
POST {AUTH_API_BASE_URL}/register
POST {AUTH_API_BASE_URL}/login
POST {AUTH_API_BASE_URL}/refresh-token
```

Response giu nguyen JSON tu ASP.NET, vi du:

```json
{
  "success": true,
  "message": "Login successfully",
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

### Tao thread

```http
POST /threads
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
  "user_id": "user-id-lay-tu-jwt",
  "created_at": "2026-05-06T08:00:00+00:00",
  "updated_at": "2026-05-06T08:00:00+00:00"
}
```

### Lay danh sach thread

```http
GET /threads
Authorization: Bearer <accessToken>
```

Chi tra ve thread cua user trong JWT.

### Gui message vao AI Agent

```http
POST /threads/{thread_id}/messages
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
    "created_at": "2026-05-06T08:01:00+00:00"
  }
}
```

Endpoint thay the neu frontend muon gui truc tiep `thread_id` va `message` trong body:

```http
POST /chat
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "thread_id": "2d4b25f4-6f15-4f30-9877-7ef31b6e5949",
  "message": "Tim giup toi khach san o Da Nang"
}
```

### Lay lich su message

```http
GET /threads/{thread_id}/messages
Authorization: Bearer <accessToken>
```

### Xoa thread

```http
DELETE /threads/{thread_id}
Authorization: Bearer <accessToken>
```

Endpoint nay xoa:

- metadata trong `chat_threads`
- message log trong `chat_messages`
- checkpoint memory cua LangGraph theo `thread_id`

## Vi du fetch frontend

```ts
const apiBase = "http://localhost:8000";

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

export async function deleteThread(accessToken: string, threadId: string) {
  await fetch(`${apiBase}/threads/${threadId}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });
}
```
