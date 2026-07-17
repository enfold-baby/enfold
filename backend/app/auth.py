import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.db import get_db
from app.models import Family, FamilyMembership, User

settings = get_settings()
_bearer = HTTPBearer(auto_error=True)


def normalize_email(email: str) -> str:
    return email.strip().lower()


def generate_magic_code() -> str:
    return f"{secrets.randbelow(1_000_000):06d}"


def create_token(user_id: uuid.UUID) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "iat": now,
        "exp": now + timedelta(minutes=settings.jwt_expire_minutes),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


async def get_or_create_user_with_family(db: AsyncSession, email: str) -> User:
    normalized = normalize_email(email)
    user = (await db.execute(select(User).where(User.email == normalized))).scalar_one_or_none()
    if user:
        return user

    user = User(email=normalized)
    family = Family(name="My family")
    db.add_all([user, family])
    await db.flush()
    db.add(FamilyMembership(user_id=user.id, family_id=family.id, role="owner"))
    await db.commit()
    await db.refresh(user)
    return user


async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(_bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    try:
        payload = jwt.decode(creds.credentials, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id = uuid.UUID(payload["sub"])
    except (jwt.PyJWTError, KeyError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user = (await db.execute(select(User).where(User.id == user_id))).scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user


async def require_family_id(user: User, db: AsyncSession) -> uuid.UUID:
    membership = (
        await db.execute(select(FamilyMembership).where(FamilyMembership.user_id == user.id))
    ).scalar_one_or_none()
    if membership is None:
        raise HTTPException(status_code=403, detail="No family access")
    return membership.family_id
