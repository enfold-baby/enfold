"""Public app version check + APK download for Android sideload beta.

Modeled on Artsani Digital's /api/app-version flow.
"""

from __future__ import annotations

import json
import shutil
from pathlib import Path

from fastapi import APIRouter, File, Header, HTTPException, UploadFile
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

from app.config import get_settings

router = APIRouter(prefix="/v1/app-version", tags=["app-version"])

_BACKEND_ROOT = Path(__file__).resolve().parents[2]
_VERSION_FILE = _BACKEND_ROOT / "app_version.json"
_APK_PATH = _BACKEND_ROOT / "uploads" / "bloomdue-baby.apk"


class AppVersionUpdate(BaseModel):
    version: str | None = Field(default=None, max_length=32)
    build_number: int | None = Field(default=None, ge=1)
    force_update: bool | None = None
    download_url: str | None = Field(default=None, max_length=500)


def _default_state() -> dict:
    return {
        "version": "0.1.0",
        "build_number": 1,
        "force_update": False,
        "download_url": "/v1/app-version/download",
    }


def _load_state() -> dict:
    if not _VERSION_FILE.exists():
        state = _default_state()
        _save_state(state)
        return state
    try:
        data = json.loads(_VERSION_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return _default_state()
    base = _default_state()
    base.update({k: data[k] for k in base if k in data})
    return base


def _save_state(state: dict) -> None:
    _VERSION_FILE.parent.mkdir(parents=True, exist_ok=True)
    _VERSION_FILE.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")


def _require_admin(token: str | None) -> None:
    expected = (get_settings().app_version_admin_token or "").strip()
    if not expected:
        raise HTTPException(
            status_code=503,
            detail="App version admin token is not configured (APP_VERSION_ADMIN_TOKEN).",
        )
    if not token or token.strip() != expected:
        raise HTTPException(status_code=401, detail="Invalid admin token")


@router.get("")
async def get_app_version() -> dict:
    """Public — mobile checks this without auth."""
    return _load_state()


@router.put("")
async def update_app_version(
    payload: AppVersionUpdate,
    x_admin_token: str | None = Header(default=None, alias="X-Admin-Token"),
) -> dict:
    """Update version metadata (admin token required)."""
    _require_admin(x_admin_token)
    state = _load_state()
    if payload.version is not None:
        state["version"] = payload.version.strip()
    if payload.build_number is not None:
        state["build_number"] = payload.build_number
    if payload.force_update is not None:
        state["force_update"] = payload.force_update
    if payload.download_url is not None:
        state["download_url"] = payload.download_url.strip()
    _save_state(state)
    return state


@router.get("/download")
async def download_apk():
    """Public — serves the uploaded APK."""
    if not _APK_PATH.exists():
        raise HTTPException(status_code=404, detail="APK not uploaded yet")
    return FileResponse(
        path=_APK_PATH,
        media_type="application/vnd.android.package-archive",
        filename="bloomdue-baby.apk",
    )


@router.post("/upload")
async def upload_apk(
    file: UploadFile = File(...),
    x_admin_token: str | None = Header(default=None, alias="X-Admin-Token"),
) -> dict:
    """Upload a new APK (admin token required)."""
    _require_admin(x_admin_token)
    name = (file.filename or "").lower()
    if not name.endswith(".apk"):
        raise HTTPException(status_code=400, detail="File must be a .apk")

    _APK_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(_APK_PATH, "wb") as out:
        shutil.copyfileobj(file.file, out)

    size_mb = round(_APK_PATH.stat().st_size / (1024 * 1024), 1)
    return {"message": f"APK uploaded ({size_mb} MB)", "path": str(_APK_PATH.name)}
