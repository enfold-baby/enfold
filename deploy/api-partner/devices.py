from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user
from app.db import get_db
from app.models import Device, User
from app.schemas import DeviceRegister, DeviceUnregister

router = APIRouter(prefix="/v1/devices", tags=["devices"])


@router.post("")
async def register_device(
    payload: DeviceRegister,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    now = datetime.now(timezone.utc)
    existing = (
        await db.execute(select(Device).where(Device.fcm_token == payload.fcm_token))
    ).scalar_one_or_none()
    if existing is not None:
        existing.user_id = user.id
        existing.platform = payload.platform
        existing.last_seen_at = now
    else:
        db.add(
            Device(
                user_id=user.id,
                platform=payload.platform,
                fcm_token=payload.fcm_token,
                last_seen_at=now,
            )
        )
    await db.commit()
    return {"status": "registered"}


@router.post("/unregister")
async def unregister_device(
    payload: DeviceUnregister,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    await db.execute(
        delete(Device).where(
            Device.user_id == user.id,
            Device.fcm_token == payload.fcm_token,
        )
    )
    await db.commit()
    return {"status": "unregistered"}
