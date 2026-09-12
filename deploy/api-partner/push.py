from __future__ import annotations

import asyncio
import logging
import uuid

import httpx
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import Device, FamilyMembership
from app.services.firebase_credentials import load_service_account_info, token_is_unregistered

logger = logging.getLogger("enfold.push")

_FCM_SCOPE = ("https://www.googleapis.com/auth/firebase.messaging",)


class PushSender:
    def __init__(self) -> None:
        self.settings = get_settings()
        self._creds = None
        self._info_error: str | None = None

    @property
    def configured(self) -> bool:
        if not (self.settings.firebase_project_id or "").strip():
            return False
        raw = (self.settings.firebase_service_account_json or "").strip()
        if not raw:
            return False
        try:
            return load_service_account_info(raw) is not None
        except Exception as exc:  # noqa: BLE001 — config probe, logged once
            self._info_error = str(exc)
            logger.warning("FCM service account is set but unreadable: %s", exc)
            return False

    def _credentials(self):
        if self._creds is not None:
            return self._creds
        info = load_service_account_info(self.settings.firebase_service_account_json)
        if info is None:
            return None
        self._creds = service_account.Credentials.from_service_account_info(
            info,
            scopes=_FCM_SCOPE,
        )
        return self._creds

    def _access_token(self) -> str:
        creds = self._credentials()
        if creds is None:
            raise RuntimeError("FCM is not configured")
        if not creds.valid:
            creds.refresh(Request())
        return creds.token

    async def send(self, fcm_token: str, title: str, body: str) -> bool:
        """Send one FCM message. Returns False when the token should be dropped."""
        if not self.configured:
            return True
        project_id = self.settings.firebase_project_id.strip()
        url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
        payload = {
            "message": {
                "token": fcm_token,
                "notification": {"title": title, "body": body},
                "data": {"type": "partner_activity"},
                "android": {
                    "priority": "HIGH",
                    "notification": {"channel_id": "partner_activity"},
                },
                "apns": {"payload": {"aps": {"sound": "default"}}},
            }
        }

        def _post() -> httpx.Response:
            access = self._access_token()
            with httpx.Client(timeout=15.0) as client:
                return client.post(
                    url,
                    headers={"Authorization": f"Bearer {access}"},
                    json=payload,
                )

        try:
            response = await asyncio.to_thread(_post)
        except Exception:
            logger.exception("FCM send failed")
            return True

        if response.status_code == 200:
            return True

        parsed: dict = {}
        try:
            parsed = response.json()
        except ValueError:
            parsed = {}
        drop = token_is_unregistered(response.status_code, parsed)
        logger.warning(
            "FCM send rejected status=%s drop_token=%s",
            response.status_code,
            drop,
        )
        return not drop

    # Back-compat name used by older deploy snapshots.
    async def send_placeholder(self, fcm_token: str, title: str, body: str) -> None:
        await self.send(fcm_token, title, body)


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

    devices = (
        await db.execute(select(Device).where(Device.user_id.in_(partner_ids)))
    ).scalars().all()
    stale_ids: list[uuid.UUID] = []
    for device in devices:
        keep = await sender.send(device.fcm_token, title, body)
        if not keep:
            stale_ids.append(device.id)
    if stale_ids:
        await db.execute(delete(Device).where(Device.id.in_(stale_ids)))
        await db.commit()
