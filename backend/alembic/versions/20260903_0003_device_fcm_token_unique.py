"""unique fcm token on devices

Revision ID: 20260903_0003
Revises: 20260810_0002
Create Date: 2026-09-03

Idempotent: safe if the unique index already exists.
"""

from alembic import op

revision = "20260903_0003"
down_revision = "20260810_0002"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        """
        DELETE FROM devices a
        USING devices b
        WHERE a.fcm_token = b.fcm_token
          AND a.last_seen_at < b.last_seen_at;
        """
    )
    op.execute(
        """
        DELETE FROM devices a
        USING devices b
        WHERE a.fcm_token = b.fcm_token
          AND a.id < b.id;
        """
    )
    op.execute(
        """
        CREATE UNIQUE INDEX IF NOT EXISTS ux_devices_fcm_token
          ON devices (fcm_token);
        """
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS ux_devices_fcm_token;")
