"""supporters wall

Revision ID: 20260912_0004
Revises: 20260903_0003
Create Date: 2026-09-12
"""

from alembic import op

revision = "20260912_0004"
down_revision = "20260903_0003"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        """
        CREATE TABLE IF NOT EXISTS supporters (
            id UUID PRIMARY KEY,
            stripe_session_id VARCHAR(255) NOT NULL UNIQUE,
            livemode BOOLEAN NOT NULL DEFAULT TRUE,
            amount_cents INTEGER NOT NULL,
            currency VARCHAR(8) NOT NULL,
            tier VARCHAR(16) NOT NULL,
            email VARCHAR(255) NOT NULL DEFAULT '',
            full_name VARCHAR(255) NOT NULL DEFAULT '',
            business_name VARCHAR(255) NOT NULL DEFAULT '',
            tax_id VARCHAR(64) NOT NULL DEFAULT '',
            address JSONB NOT NULL DEFAULT '{}'::jsonb,
            show_on_wall BOOLEAN NOT NULL DEFAULT FALSE,
            link VARCHAR(512) NOT NULL DEFAULT '',
            icon_content_type VARCHAR(64) NOT NULL DEFAULT '',
            icon BYTEA,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        );
        """
    )
    op.execute("CREATE INDEX IF NOT EXISTS ix_supporters_livemode ON supporters (livemode);")


def downgrade() -> None:
    op.execute("DROP TABLE IF EXISTS supporters;")
