import base64
import json
import time

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel


bearer_scheme = HTTPBearer(
    auto_error=False,
    scheme_name="Bearer Auth",
    description="Nhap access token theo dang Bearer <token>",
)


class AuthContext(BaseModel):
    user_id: str
    access_token: str
    claims: dict


def decode_jwt_payload(token: str) -> dict:
    parts = token.split(".")
    if len(parts) != 3:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Access token khong dung dinh dang JWT.",
        )

    payload = parts[1]
    padding = "=" * (-len(payload) % 4)
    try:
        decoded = base64.urlsafe_b64decode(payload + padding)
        return json.loads(decoded)
    except (ValueError, json.JSONDecodeError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Khong doc duoc payload cua access token.",
        ) from exc


def get_claim(payload: dict, names: tuple[str, ...]) -> str | None:
    for name in names:
        value = payload.get(name)
        if value:
            return str(value)
    return None


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> AuthContext:
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Thieu Authorization header.",
        )

    if credentials.scheme.lower() != "bearer" or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header phai co dang Bearer <accessToken>.",
        )

    token = credentials.credentials
    payload = decode_jwt_payload(token)
    expires_at = payload.get("exp")
    if expires_at and int(expires_at) < int(time.time()):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Access token da het han.",
        )

    user_id = get_claim(
        payload,
        (
            "sub",
            "nameid",
            "userId",
            "uid",
            "id",
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier",
        ),
    )
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Access token khong co claim user id.",
        )

    return AuthContext(user_id=user_id, access_token=token, claims=payload)
