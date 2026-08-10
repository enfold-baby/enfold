"""Partner family: me / invite / join."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.auth import get_current_user, require_family_id
from app.db import get_db
from app.models import Family, FamilyMembership, User
from app.schemas import (
    FamilyInfoResponse,
    FamilyInviteResponse,
    FamilyJoinRequest,
    FamilyMemberResponse,
)
from app.services.invites import InviteStore

router = APIRouter(prefix="/v1/families", tags=["families"])
invite_store = InviteStore()


async def _membership_for(user: User, db: AsyncSession) -> FamilyMembership:
    membership = (
        await db.execute(
            select(FamilyMembership).where(FamilyMembership.user_id == user.id)
        )
    ).scalar_one_or_none()
    if membership is None:
        raise HTTPException(status_code=403, detail="No family access")
    return membership


async def _family_info(family_id: uuid.UUID, db: AsyncSession) -> FamilyInfoResponse:
    memberships = (
        await db.execute(
            select(FamilyMembership)
            .where(FamilyMembership.family_id == family_id)
            .options(selectinload(FamilyMembership.user))
        )
    ).scalars().all()

    members: list[FamilyMemberResponse] = []
    for m in memberships:
        u = m.user
        members.append(
            FamilyMemberResponse(
                id=u.id,
                email=u.email,
                display_name=u.display_name or "",
            )
        )

    invite_code = await invite_store.get_active_code(str(family_id))
    return FamilyInfoResponse(
        id=family_id,
        invite_code=invite_code,
        members=members,
    )


@router.get("/me", response_model=FamilyInfoResponse)
async def get_my_family(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> FamilyInfoResponse:
    family_id = await require_family_id(user, db)
    return await _family_info(family_id, db)


@router.post("/invites", response_model=FamilyInviteResponse)
async def create_family_invite(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> FamilyInviteResponse:
    family_id = await require_family_id(user, db)
    code, expires = await invite_store.create(str(family_id))
    return FamilyInviteResponse(code=code, expires_at=expires)


@router.post("/join", response_model=FamilyInfoResponse)
async def join_family(
    payload: FamilyJoinRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> FamilyInfoResponse:
    code = payload.code.strip().upper()
    target_family_id_raw = await invite_store.resolve_family_id(code)
    if not target_family_id_raw:
        raise HTTPException(status_code=404, detail="Invite code not found or expired")

    try:
        target_family_id = uuid.UUID(target_family_id_raw)
    except ValueError:
        raise HTTPException(status_code=404, detail="Invite code not found or expired")

    family = (
        await db.execute(select(Family).where(Family.id == target_family_id))
    ).scalar_one_or_none()
    if family is None:
        raise HTTPException(status_code=404, detail="Invite code not found or expired")

    membership = await _membership_for(user, db)
    if membership.family_id == target_family_id:
        return await _family_info(target_family_id, db)

    # Move this user into the inviter's family (one membership per user).
    membership.family_id = target_family_id
    membership.role = "parent"
    await db.commit()
    return await _family_info(target_family_id, db)


@router.post("/leave", response_model=FamilyInfoResponse)
async def leave_family(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> FamilyInfoResponse:
    """Leave a shared family. Partner's family data stays intact.

    The leaving user is placed in a fresh solo family so the app still has
    a family_id for children / care events they create later.
    """
    membership = await _membership_for(user, db)
    family_id = membership.family_id

    member_count = len(
        (
            await db.execute(
                select(FamilyMembership).where(FamilyMembership.family_id == family_id)
            )
        )
        .scalars()
        .all()
    )
    if member_count <= 1:
        raise HTTPException(
            status_code=400,
            detail="You are not in a shared family — nothing to leave.",
        )

    # Detach from shared family; do not delete their children / care_events.
    await db.delete(membership)
    await db.flush()

    solo = Family(name="My family")
    db.add(solo)
    await db.flush()
    db.add(
        FamilyMembership(
            user_id=user.id,
            family_id=solo.id,
            role="owner",
        )
    )
    await db.commit()
    return await _family_info(solo.id, db)
