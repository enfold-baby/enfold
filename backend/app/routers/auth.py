from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import create_token, generate_magic_code, get_current_user, get_or_create_user_with_family, normalize_email
from app.config import get_settings
from app.db import get_db
from app.models import User
from app.schemas import (
    MagicCodeRequest,
    MagicCodeVerify,
    MeResponse,
    TokenResponse,
    UserProfileUpdate,
    UserResponse,
)
from app.services.email import EmailSender
from app.services.otp import OtpStore

router = APIRouter(prefix="/v1/auth", tags=["auth"])
otp_store = OtpStore()
email_sender = EmailSender()


@router.post("/magic-code/request")
async def request_magic_code(payload: MagicCodeRequest) -> dict:
    email = normalize_email(payload.email)
    code = generate_magic_code()
    await otp_store.save(email, code)
    await email_sender.send_magic_code(email, code)
    response = {"status": "sent"}
    # TODO: Remove this dev_code response after real email delivery is enabled.
    if get_settings().dev_magic_code_log:
        response["dev_code"] = code
    return response


@router.post("/magic-code/verify", response_model=TokenResponse)
async def verify_magic_code(payload: MagicCodeVerify, db: AsyncSession = Depends(get_db)) -> TokenResponse:
    email = normalize_email(payload.email)
    if not await otp_store.verify(email, payload.code):
        raise HTTPException(status_code=401, detail="Invalid or expired code")
    user = await get_or_create_user_with_family(db, email)
    return TokenResponse(access_token=create_token(user.id))


@router.get("/me", response_model=MeResponse)
async def me(user: User = Depends(get_current_user)) -> MeResponse:
    return MeResponse(user=UserResponse(id=user.id, email=user.email, display_name=user.display_name))


@router.patch("/me", response_model=MeResponse)
async def update_me(
    payload: UserProfileUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> MeResponse:
    """Update caregiver display name (shown on logs as “who logged this”)."""
    user.display_name = (payload.display_name or "").strip()[:120]
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return MeResponse(
        user=UserResponse(id=user.id, email=user.email, display_name=user.display_name)
    )
