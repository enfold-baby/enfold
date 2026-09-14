import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user, require_family_id
from app.db import get_db
from app.models import CareEvent, Child, User
from app.schemas import CareEventCreate, CareEventResponse, CareEventUpdate
from app.services.push import notify_family_partners

router = APIRouter(prefix="/v1/care-events", tags=["care-events"])

_PARTNER_PUSH_TYPES = {"feeding", "diaper", "sleep"}
_TYPE_LABELS = {
    "feeding": "Feed",
    "diaper": "Diaper",
    "sleep": "Sleep",
    "pumping": "Pumping",
    "medication": "Medication",
    "note": "Note",
}


def _author_display_name(user: User) -> str:
    name = (user.display_name or "").strip()
    if name:
        return name
    local = user.email.split("@")[0].strip()
    return local.capitalize() if local else "Partner"


async def _assert_child_access(db: AsyncSession, child_id: uuid.UUID, family_id: uuid.UUID) -> Child:
    child = (
        await db.execute(select(Child).where(Child.id == child_id, Child.family_id == family_id))
    ).scalar_one_or_none()
    if child is None:
        raise HTTPException(status_code=404, detail="Child not found")
    return child


async def _get_event_for_family(
    db: AsyncSession, event_id: uuid.UUID, family_id: uuid.UUID
) -> CareEvent:
    event = (
        await db.execute(
            select(CareEvent).where(
                CareEvent.id == event_id,
                CareEvent.family_id == family_id,
            )
        )
    ).scalar_one_or_none()
    if event is None:
        raise HTTPException(status_code=404, detail="Care event not found")
    return event


@router.get("", response_model=list[CareEventResponse])
async def list_care_events(
    child_id: uuid.UUID,
    since: datetime | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[CareEvent]:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, child_id, family_id)
    query = (
        select(CareEvent)
        .where(CareEvent.child_id == child_id, CareEvent.family_id == family_id)
        .order_by(CareEvent.occurred_at.desc())
    )
    # Clients that send `since` reconcile deletions over that window, so they
    # need every row in it. Older app builds send nothing and keep the cap.
    if since is None:
        query = query.limit(200)
    else:
        query = query.where(CareEvent.occurred_at >= since)
    rows = await db.execute(query)
    return list(rows.scalars().all())


@router.post("", response_model=CareEventResponse)
async def create_care_event(
    payload: CareEventCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CareEvent:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, payload.child_id, family_id)
    author_name = _author_display_name(user)
    event = CareEvent(
        id=payload.id or uuid.uuid4(),
        child_id=payload.child_id,
        family_id=family_id,
        type=payload.type,
        occurred_at=payload.occurred_at,
        details=payload.details,
        note=payload.note,
        client_updated_at=payload.client_updated_at,
        created_by_user_id=user.id,
        created_by_display_name=author_name,
    )
    db.add(event)
    await db.commit()
    await db.refresh(event)

    if payload.type in _PARTNER_PUSH_TYPES:
        label = _TYPE_LABELS.get(payload.type, payload.type)
        await notify_family_partners(
            db,
            family_id=family_id,
            actor_user_id=user.id,
            title=f"{author_name} logged {label.lower()}",
            body="Open Enfold to see the latest update.",
        )

    return event


@router.patch("/{event_id}", response_model=CareEventResponse)
async def update_care_event(
    event_id: uuid.UUID,
    payload: CareEventUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CareEvent:
    family_id = await require_family_id(user, db)
    event = await _get_event_for_family(db, event_id, family_id)

    if payload.type is not None:
        event.type = payload.type
    if payload.occurred_at is not None:
        event.occurred_at = payload.occurred_at
    if payload.details is not None:
        event.details = payload.details
    if payload.note is not None:
        event.note = payload.note
    if payload.client_updated_at is not None:
        event.client_updated_at = payload.client_updated_at

    await db.commit()
    await db.refresh(event)
    return event


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_care_event(
    event_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Response:
    family_id = await require_family_id(user, db)
    event = await _get_event_for_family(db, event_id, family_id)
    await db.delete(event)
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)