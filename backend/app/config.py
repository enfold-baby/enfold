from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_env: str = "development"
    database_url: str = "postgresql+asyncpg://bloomdue:bloomdue_dev_change_me@postgres:5432/bloomdue"
    redis_url: str = "redis://redis:6379/0"
    cors_allow_origins: str = "http://localhost:8280"

    jwt_secret: str = "dev-insecure-change-me"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60 * 24 * 7

    magic_code_expire_minutes: int = 10
    dev_magic_code_log: bool = True

    # Store-review account: this email always gets reviewer_code as its sign-in
    # code and no email is sent, so a Play reviewer can log in without an inbox.
    # Both must be set on the server for it to apply; empty disables it.
    reviewer_email: str = ""
    reviewer_code: str = ""

    smtp_host: str = ""
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    smtp_from_email: str = "noreply@enfold.baby"
    smtp_from_name: str = "Enfold"
    smtp_use_ssl: bool = False

    # AWS SES (eu-central-1). Keys are required on the OVH VPS (no instance role).
    ses_region: str = ""
    ses_access_key_id: str = ""
    ses_secret_access_key: str = ""

    # Human inbox for replies and launch-notify form notifications.
    contact_email: str = "support@enfold.baby"
    beta_request_to_email: str = "support@enfold.baby"
    beta_request_rate_limit_per_ip: int = 5
    beta_request_rate_limit_window_seconds: int = 3600

    ms_graph_tenant_id: str = ""
    ms_graph_client_id: str = ""
    ms_graph_client_secret: str = ""
    ms_graph_sender: str = ""

    firebase_project_id: str = ""
    firebase_service_account_json: str = ""

    # Stripe webhook signing secrets (Developers > Webhooks). Live and sandbox
    # endpoints have different secrets; either may be empty to disable.
    stripe_webhook_secret: str = ""
    stripe_webhook_secret_test: str = ""

    # Protects APK upload + version metadata PUT (sideload beta ops).
    app_version_admin_token: str = ""

    @property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.cors_allow_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()