"""Supporters wall: Stripe webhook in, public totals and moons out."""

from __future__ import annotations

import json
import logging
from urllib.parse import urlparse

import httpx
from fastapi import APIRouter, Depends, HTTPException, Request, Response
from fastapi.responses import JSONResponse
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.db import get_db
from app.models import Supporter
from app.services.stripe_webhook import parse_checkout_session, verify_signature

router = APIRouter(prefix="/v1", tags=["support"])
logger = logging.getLogger("enfold.support")

ICON_MAX_BYTES = 120_000
ICON_TYPES = {"image/png", "image/x-icon", "image/vnd.microsoft.icon", "image/svg+xml", "image/jpeg", "image/webp", "image/gif"}


async def fetch_icon(link: str) -> tuple[str, bytes | None]:
    """Best-effort favicon for a supporter's link, fetched server-side so
    visitors never call a third party. Empty on any failure."""
    host = urlparse(link).netloc
    if not host:
        return "", None
    try:
        async with httpx.AsyncClient(timeout=6, follow_redirects=True, headers={"User-Agent": "Enfold supporters wall"}) as client:
            resp = await client.get(f"https://{host}/favicon.ico")
            if resp.status_code != 200:
                return "", None
            ctype = resp.headers.get("content-type", "").split(";")[0].strip().lower()
            if ctype not in ICON_TYPES or len(resp.content) > ICON_MAX_BYTES or not resp.content:
                return "", None
            return ctype, resp.content
    except Exception:
        return "", None


@router.post("/stripe/webhook", status_code=200)
async def stripe_webhook(request: Request, db: AsyncSession = Depends(get_db)) -> dict:
    settings = get_settings()
    payload = await request.body()
    header = request.headers.get("stripe-signature", "")
    secrets = [s for s in (settings.stripe_webhook_secret, settings.stripe_webhook_secret_test) if s]
    if not any(verify_signature(payload, header, secret) for secret in secrets):
        raise HTTPException(status_code=400, detail="Invalid signature")
    try:
        event = json.loads(payload)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid payload") from None
    if event.get("type") != "checkout.session.completed":
        return {"received": True, "ignored": event.get("type")}
    session = (event.get("data") or {}).get("object") or {}
    if session.get("payment_status") not in (None, "paid", "no_payment_required"):
        return {"received": True, "ignored": "unpaid"}
    data = parse_checkout_session(session)
    if not data["stripe_session_id"] or data["amount_cents"] <= 0:
        return {"received": True, "ignored": "empty"}
    existing = (
        await db.execute(select(Supporter).where(Supporter.stripe_session_id == data["stripe_session_id"]))
    ).scalar_one_or_none()
    if existing is not None:
        return {"received": True, "duplicate": True}
    icon_type, icon = ("", None)
    if data["show_on_wall"] and data["link"]:
        icon_type, icon = await fetch_icon(data["link"])
    db.add(Supporter(**data, icon_content_type=icon_type, icon=icon))
    await db.commit()
    return {"received": True}


def _display_name(s: Supporter) -> str:
    name = s.business_name.strip() or s.full_name.strip()
    return name or "A parent"


PUBLIC_HEADERS = {"Access-Control-Allow-Origin": "*", "Cache-Control": "public, max-age=60"}


@router.get("/support/wall")
async def support_wall(mode: str = "live", db: AsyncSession = Depends(get_db)) -> JSONResponse:
    """Public, read-only totals and named moons; any origin may read it."""
    livemode = mode != "test"
    rows = (
        await db.execute(
            select(Supporter).where(Supporter.livemode == livemode).order_by(Supporter.amount_cents.desc(), Supporter.created_at.asc())
        )
    ).scalars().all()
    tiers = {"tea": 0, "nest": 0, "moon": 0, "wish": 0}
    total = 0
    for s in rows:
        tiers[s.tier] = tiers.get(s.tier, 0) + 1
        total += s.amount_cents
    moons = [
        {
            "id": str(s.id),
            "name": _display_name(s),
            "link": s.link or None,
            "amount_cents": s.amount_cents,
            "currency": s.currency,
            "tier": s.tier,
            "has_icon": bool(s.icon),
            "since": s.created_at.date().isoformat() if s.created_at else None,
        }
        for s in rows
        if s.show_on_wall
    ]
    return JSONResponse(
        {"count": len(rows), "total_cents": total, "currency": "eur", "tiers": tiers, "moons": moons},
        headers=PUBLIC_HEADERS,
    )


@router.get("/support/icon/{supporter_id}")
async def support_icon(supporter_id: str, db: AsyncSession = Depends(get_db)) -> Response:
    try:
        row = await db.get(Supporter, supporter_id)
    except Exception:
        row = None
    if row is None or not row.icon or not row.show_on_wall:
        raise HTTPException(status_code=404, detail="No icon")
    return Response(content=row.icon, media_type=row.icon_content_type or "image/x-icon", headers={"Cache-Control": "public, max-age=86400", "Access-Control-Allow-Origin": "*"})
