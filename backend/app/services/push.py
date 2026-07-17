import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import Device, FamilyMembership


class PushSender:
    def __init__(self) -> None:
        self.settings = get_settings()

    @property
    def configured(self) -> bool:
        return bool(self.settings.firebase_project_id and self.settings.firebase_service_account_json)

    async def send_placeholder(self, fcm_token: str, title: str, body: str) -> None:
        # Real FCM HTTP v1 signing is added once Firebase service credentials are provided.
        if not self.configured:
            return
        raise NotImplementedError("FCM dispatch is not wired yet")


_push_sender = PushSender()


def get_push_sender() -> PushSender:
    return _push_sender


async def notify_family_partners(
    db: AsyncSession,
    *,
    family_id: uuid.UUID,
    actor_user_id: uuid.UUID,
    title: str,
    body: str,
) -> None:
    """Best-effort push to other parents in the family. No-op until FCM is configured."""
    sender = get_push_sender()
    if not sender.configured:
        return

    partner_ids = (
        await db.execute(
            select(FamilyMembership.user_id).where(
                FamilyMembership.family_id == family_id,
                FamilyMembership.user_id != actor_user_id,
            )
        )
    ).scalars().all()
    if not partner_ids:
        return

    tokens = (
        await db.execute(select(Device.fcm_token).where(Device.user_id.in_(partner_ids)))
    ).scalars().all()
    for token in tokens:
        await sender.send_placeholder(token, title, body)