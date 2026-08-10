"""care event attribution columns

Revision ID: 20260810_0002
Revises: 20260608_0001
Create Date: 2026-08-10

Idempotent: safe if columns already exist (e.g. from deploy/api-partner/migration.sql).
"""

from alembic import op

revision = "20260810_0002"
down_revision = "20260608_0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Postgres-native IF NOT EXISTS so stamp/upgrade never fails on half-applied DBs.
    op.execute(
        """
        ALTER TABLE care_events
          ADD COLUMN IF NOT EXISTS created_by_user_id UUID
            REFERENCES users(id) ON DELETE SET NULL;
        """
    )
    op.execute(
        """
        ALTER TABLE care_events
          ADD COLUMN IF NOT EXISTS created_by_display_name VARCHAR(120)
            NOT NULL DEFAULT '';
        """
    )


def downgrade() -> None:
    op.execute("ALTER TABLE care_events DROP COLUMN IF EXISTS created_by_display_name;")
    op.execute("ALTER TABLE care_events DROP COLUMN IF EXISTS created_by_user_id;")
