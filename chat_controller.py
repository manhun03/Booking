from typing import Literal

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field

import chat_service
from auth_jwt import AuthContext, get_current_user


router = APIRouter()


class CreateThreadRequest(BaseModel):
    title: str | None = Field(default=None, max_length=120)


class ThreadResponse(BaseModel):
    thread_id: str
    title: str
    user_id: str | None
    created_at: str
    updated_at: str


class MessageResponse(BaseModel):
    id: int
    thread_id: str
    role: Literal["user", "assistant"]
    content: str
    created_at: str


class SendMessageRequest(BaseModel):
    message: str = Field(min_length=1)


class ChatRequest(BaseModel):
    thread_id: str = Field(min_length=1)
    message: str = Field(min_length=1)


class ChatResponse(BaseModel):
    thread_id: str
    message: MessageResponse


class RegisterRequest(BaseModel):
    fullName: str | None = None
    email: str | None = None
    phoneNumber: str | None = None
    password: str


class LoginRequest(BaseModel):
    email: str | None = None
    phoneNumber: str | None = None
    password: str


class RefreshTokenRequest(BaseModel):
    refreshToken: str


@router.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@router.post("/auth/register")
def register(payload: RegisterRequest) -> dict:
    return chat_service.post_auth_api("register", payload.model_dump(exclude_none=True))


@router.post("/auth/login")
def login(payload: LoginRequest) -> dict:
    return chat_service.post_auth_api("login", payload.model_dump(exclude_none=True))


@router.post("/auth/refresh-token")
def refresh_token(payload: RefreshTokenRequest) -> dict:
    return chat_service.post_auth_api("refresh-token", payload.model_dump())


@router.post(
    "/threads",
    response_model=ThreadResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_thread(
    payload: CreateThreadRequest,
    current_user: AuthContext = Depends(get_current_user),
) -> dict:
    return chat_service.create_thread(payload.title, current_user.user_id)


@router.get("/threads", response_model=list[ThreadResponse])
def list_threads(
    current_user: AuthContext = Depends(get_current_user),
) -> list[dict]:
    return chat_service.list_threads(current_user.user_id)


@router.get("/threads/{thread_id}", response_model=ThreadResponse)
def get_thread(
    thread_id: str,
    current_user: AuthContext = Depends(get_current_user),
) -> dict:
    return chat_service.get_thread(thread_id, current_user.user_id)


@router.delete("/threads/{thread_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_thread(
    thread_id: str,
    current_user: AuthContext = Depends(get_current_user),
) -> None:
    chat_service.delete_thread(thread_id, current_user.user_id)


@router.get("/threads/{thread_id}/messages", response_model=list[MessageResponse])
def list_messages(
    thread_id: str,
    current_user: AuthContext = Depends(get_current_user),
) -> list[dict]:
    return chat_service.list_messages(thread_id, current_user.user_id)


@router.post("/threads/{thread_id}/messages", response_model=ChatResponse)
def send_thread_message(
    thread_id: str,
    payload: SendMessageRequest,
    current_user: AuthContext = Depends(get_current_user),
) -> dict:
    return chat_service.send_message(
        thread_id,
        payload.message,
        current_user.user_id,
    )


@router.post("/chat", response_model=ChatResponse)
def send_message(
    payload: ChatRequest,
    current_user: AuthContext = Depends(get_current_user),
) -> dict:
    return chat_service.send_message(
        payload.thread_id,
        payload.message,
        current_user.user_id,
    )
