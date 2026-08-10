"""care event attribution columns

Revision ID: 20260810_0002
Revises: 20260608_0001
Create Date: 2026-08-10
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "20260810_0002"
down_revision = "20260608_0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "care_events",
        sa.Column(
            "created_by_user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="SET NULL"),
            nullable=True,
        ),
    )
    op.add_column(
        "care_events",
        sa.Column(
            "created_by_display_name",
            sa.String(length=120),
            nullable=False,
            server_default="",
        ),
    )


def downgrade() -> None:
    op.drop_column("care_events", "created_by_display_name")
    op.drop_column("care_events", "created_by_user_id")
