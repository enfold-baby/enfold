"""Supporters wall: Stripe webhook in, public totals and moons out."""

from __future__ import annotations

import asyncio
import ipaddress
import json
import logging
import re
from urllib.parse import urljoin, urlparse

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
ICON_MAX_TRIES = 4
LINK_TAG_RE = re.compile(r"<link\b[^>]*>", re.IGNORECASE)
ATTR_RE = re.compile(r"""([a-zA-Z-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))""")


def icon_candidates(html: str, page_url: str) -> list[str]:
    """Icon URLs a page declares (rel="icon" first, then apple-touch-icon),
    with /favicon.ico last. Only https URLs."""
    icons: list[str] = []
    touch: list[str] = []
    for tag in LINK_TAG_RE.findall(html[:200_000]):
        attrs = {m.group(1).lower(): m.group(2) or m.group(3) or m.group(4) or "" for m in ATTR_RE.finditer(tag)}
        rels = attrs.get("rel", "").lower().split()
        href = attrs.get("href", "").strip()
        if not href:
            continue
        if "icon" in rels:
            icons.append(urljoin(page_url, href))
        elif any(r.startswith("apple-touch-icon") for r in rels):
            touch.append(urljoin(page_url, href))
    fallback = urljoin(page_url, "/favicon.ico")
    ordered: list[str] = []
    for url in icons + touch + [fallback]:
        if urlparse(url).scheme == "https" and url not in ordered:
            ordered.append(url)
    return ordered


async def _is_public_host(host: str) -> bool:
    """Refuse loopback, private and link-local targets (the link is user input)."""
    if not host:
        return False
    try:
        infos = await asyncio.get_running_loop().getaddrinfo(host, 443)
    except OSError:
        return False
    for info in infos:
        ip = ipaddress.ip_address(info[4][0])
        if not ip.is_global:
            return False
    return bool(infos)


async def _guard_request(request: httpx.Request) -> None:
    if request.url.scheme != "https" or not await _is_public_host(request.url.host):
        raise httpx.RequestError("Blocked icon host", request=request)


async def fetch_icon(link: str) -> tuple[str, bytes | None]:
    """Best-effort favicon for a supporter's link, fetched server-side so
    visitors never call a third party. Empty on any failure."""
    host = urlparse(link).netloc
    if not host:
        return "", None
    page_url = f"https://{host}/"
    try:
        async with httpx.AsyncClient(
            timeout=6,
            follow_redirects=True,
            max_redirects=3,
            headers={"User-Agent": "Enfold supporters wall"},
            event_hooks={"request": [_guard_request]},
        ) as client:
            candidates = [urljoin(page_url, "/favicon.ico")]
            try:
                page = await client.get(page_url)
                if page.status_code == 200 and "html" in page.headers.get("content-type", ""):
                    candidates = icon_candidates(page.text, str(page.url))
            except httpx.HTTPError:
                pass
            for url in candidates[:ICON_MAX_TRIES]:
                try:
                    resp = await client.get(url)
                except httpx.HTTPError:
                    continue
                ctype = resp.headers.get("content-type", "").split(";")[0].strip().lower()
                if resp.status_code == 200 and ctype in ICON_TYPES and 0 < len(resp.content) <= ICON_MAX_BYTES:
                    return ctype, resp.content
    except Exception:
        logger.info("icon fetch failed for %s", host)
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
