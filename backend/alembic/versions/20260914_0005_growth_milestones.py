"""growth measurements and milestones shared across the family

Revision ID: 20260914_0005
Revises: 20260912_0004
Create Date: 2026-09-14

Until now both lived only on each phone, so a partner never saw them.
"""

from alembic import op

revision = "20260914_0005"
down_revision = "20260912_0004"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        """
        CREATE TABLE IF NOT EXISTS growth_measurements (
            id UUID PRIMARY KEY,
            child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
            family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
            measured_at TIMESTAMPTZ NOT NULL,
            weight_kg DOUBLE PRECISION,
            length_cm DOUBLE PRECISION,
            head_cm DOUBLE PRECISION,
            note TEXT NOT NULL DEFAULT '',
            created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        );
        """
    )
    op.execute("CREATE INDEX IF NOT EXISTS ix_growth_measurements_child_id ON growth_measurements (child_id);")
    op.execute("CREATE INDEX IF NOT EXISTS ix_growth_measurements_family_id ON growth_measurements (family_id);")
    op.execute(
        """
        CREATE TABLE IF NOT EXISTS milestone_achievements (
            id UUID PRIMARY KEY,
            child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
            family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
            milestone_key VARCHAR(64) NOT NULL,
            achieved_at TIMESTAMPTZ NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            UNIQUE (child_id, milestone_key)
        );
        """
    )
    op.execute("CREATE INDEX IF NOT EXISTS ix_milestone_achievements_child_id ON milestone_achievements (child_id);")
    op.execute("CREATE INDEX IF NOT EXISTS ix_milestone_achievements_family_id ON milestone_achievements (family_id);")


def downgrade() -> None:
    op.execute("DROP TABLE IF EXISTS milestone_achievements;")
    op.execute("DROP TABLE IF EXISTS growth_measurements;")
