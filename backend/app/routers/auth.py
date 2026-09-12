import logging

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import create_token, generate_magic_code, get_current_user, get_or_create_user_with_family, normalize_email
from app.config import get_settings
from app.db import get_db
from app.models import Family, FamilyMembership, User
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
logger = logging.getLogger("enfold.auth")


@router.post("/magic-code/request")
async def request_magic_code(payload: MagicCodeRequest) -> dict:
    email = normalize_email(payload.email)
    settings = get_settings()
    if settings.reviewer_email and settings.reviewer_code and email == normalize_email(settings.reviewer_email):
        # Store-review account: fixed code, no email.
        await otp_store.save(email, settings.reviewer_code)
        return {"status": "sent"}
    code = generate_magic_code()
    await otp_store.save(email, code)
    try:
        await email_sender.send_magic_code(email, code)
    except Exception:
        logger.exception("magic-code email failed for %s", email)
        raise HTTPException(
            status_code=503,
            detail="Could not send sign-in code. Try again in a moment.",
        ) from None
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


@router.delete("/me", status_code=204)
async def delete_me(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Response:
    """Permanently delete this account. If the user is the last family member, the family and care record go too."""
    membership = (
        await db.execute(select(FamilyMembership).where(FamilyMembership.user_id == user.id))
    ).scalar_one_or_none()
    if membership is not None:
        remaining = (
            await db.execute(
                select(func.count())
                .select_from(FamilyMembership)
                .where(
                    FamilyMembership.family_id == membership.family_id,
                    FamilyMembership.user_id != user.id,
                )
            )
        ).scalar_one()
        if remaining == 0:
            family = await db.get(Family, membership.family_id)
            if family is not None:
                await db.delete(family)
    await db.delete(user)
    await db.commit()
    return Response(status_code=204)
