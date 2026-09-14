from fastapi import FastAPI
from starlette.requests import Request
from starlette.responses import Response

from app.config import get_settings
from app.routers import (
    app_version,
    auth,
    beta_requests,
    care_events,
    children,
    devices,
    families,
    growth,
    health,
    support,
)

settings = get_settings()
allowed_origins = set(settings.cors_origins)

app = FastAPI(title="Enfold API", version="0.1.0")


@app.middleware("http")
async def cors(request: Request, call_next):
    origin = request.headers.get("origin")
    allow_origin = origin if origin and origin in allowed_origins else None

    if request.method == "OPTIONS":
        response = Response(status_code=204)
    else:
        response = await call_next(request)

    if allow_origin:
        response.headers["Access-Control-Allow-Origin"] = allow_origin
        response.headers["Vary"] = "Origin"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, PATCH, DELETE, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type"
        response.headers["Access-Control-Allow-Credentials"] = "true"
    return response


app.include_router(health.router)
app.include_router(auth.router)
app.include_router(app_version.router)
app.include_router(beta_requests.router)
app.include_router(children.router)
app.include_router(care_events.router)
app.include_router(devices.router)
app.include_router(families.router)
app.include_router(growth.router)
app.include_router(support.router)


@app.get("/")
async def root() -> dict:
    return {"service": "enfold-api", "docs": "/docs"}
