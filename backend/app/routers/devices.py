from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user
from app.db import get_db
from app.models import Device, User
from app.schemas import DeviceRegister

router = APIRouter(prefix="/v1/devices", tags=["devices"])


@router.post("")
async def register_device(
    payload: DeviceRegister,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict:
    device = Device(
        user_id=user.id,
        platform=payload.platform,
        fcm_token=payload.fcm_token,
        last_seen_at=datetime.now(timezone.utc),
    )
    db.add(device)
    await db.commit()
    return {"status": "registered"}
