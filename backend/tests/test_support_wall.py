import hashlib
import hmac
import json
import time

from app.services.stripe_webhook import clean_link, parse_checkout_session, tier_for, verify_signature


def _sign(payload: bytes, secret: str, ts: int) -> str:
    sig = hmac.new(secret.encode(), f"{ts}.".encode() + payload, hashlib.sha256).hexdigest()
    return f"t={ts},v1={sig}"


def test_signature_accepts_valid_and_rejects_tampered() -> None:
    body = b'{"id":"evt_1"}'
    ts = int(time.time())
    header = _sign(body, "whsec_test", ts)
    assert verify_signature(body, header, "whsec_test", now=ts)
    assert not verify_signature(body + b" ", header, "whsec_test", now=ts)
    assert not verify_signature(body, header, "whsec_other", now=ts)
    assert not verify_signature(body, header, "whsec_test", now=ts + 1000)  # stale
    assert not verify_signature(body, "", "whsec_test", now=ts)


def test_tiers_and_links() -> None:
    assert tier_for(500, 1) == "tea"
    assert tier_for(1200, 1) == "nest"
    assert tier_for(3000, 1) == "moon"
    assert tier_for(700, 7) == "wish"
    # A 5 EUR wish (quantity 5, no line items in the webhook) must stay a wish.
    assert tier_for(500, 1, "plink_1UEmQZE71DM0rnaDhXL4R4MW") == "wish"
    assert tier_for(500, 1, "plink_unknown") == "tea"
    assert tier_for(500, 1, "plink_1UEms5E71DM0rnaDlUHfgIjf") == "wish"  # sandbox wish
    assert clean_link("enfold.baby") == "https://enfold.baby"
    assert clean_link("javascript:alert(1)") == ""
    assert clean_link("  ") == ""


def test_parse_checkout_session_reads_custom_fields() -> None:
    session = {
        "id": "cs_test_1",
        "livemode": False,
        "amount_total": 1200,
        "currency": "eur",
        "payment_status": "paid",
        "customer_details": {
            "email": "a@b.c",
            "name": "Raul Test",
            "address": {"city": "Baia Mare", "country": "RO", "line1": "Str. Lazuri 18", "postal_code": "430414", "line2": None},
        },
        "business_name": "GLOBINARY DEVELOPMENT SYSTEM SRL",
        "custom_fields": [
            {"key": "taxidorcuioptionalforaninvoice", "type": "text", "text": {"value": "RO54530880"}},
            {"key": "showmymoononthesupporterswall", "type": "dropdown", "dropdown": {"value": "Yes, show my name"}},
            {"key": "yourwebsiteorprofilelinkoptional", "type": "text", "text": {"value": "globinary.io"}},
        ],
    }
    data = parse_checkout_session(session)
    assert data["tier"] == "nest"
    assert data["tax_id"] == "RO54530880"
    assert data["show_on_wall"] is True
    assert data["link"] == "https://globinary.io"
    assert data["business_name"].startswith("GLOBINARY")
    assert data["address"]["city"] == "Baia Mare" and "line2" not in data["address"]
    assert data["livemode"] is False


def test_icon_candidates_prefer_declared_icons() -> None:
    from app.routers.support import icon_candidates

    html = """<head>
      <link rel="apple-touch-icon" href="/apple-touch-icon.png" sizes="180x180" />
      <link rel="icon" href="/favicon.png?v=1" type="image/png" />
      <link rel='shortcut icon' href='https://cdn.example.com/i.ico'>
      <link rel="icon" href="http://insecure.example.com/x.png">
      <link rel="stylesheet" href="/styles.css" />
    </head>"""
    assert icon_candidates(html, "https://enfold.baby/") == [
        "https://enfold.baby/favicon.png?v=1",
        "https://cdn.example.com/i.ico",
        "https://enfold.baby/apple-touch-icon.png",
        "https://enfold.baby/favicon.ico",
    ]
    assert icon_candidates("<html></html>", "https://globinary.io/en") == ["https://globinary.io/favicon.ico"]


def test_moon_json_carries_planting_time() -> None:
    from datetime import datetime, timezone
    from types import SimpleNamespace

    from app.routers.support import _moon_json

    row = SimpleNamespace(
        id="abc", business_name="", full_name="Ana Pop", link="", amount_cents=500, currency="eur",
        tier="tea", icon=None, created_at=datetime(2026, 9, 14, 10, 41, 9, tzinfo=timezone.utc),
    )
    moon = _moon_json(row)
    assert moon["planted_at"] == "2026-09-14T10:41:09+00:00"
    assert moon["since"] == "2026-09-14"
    assert moon["name"] == "Ana Pop" and moon["link"] is None and moon["has_icon"] is False
