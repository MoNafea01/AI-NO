"""add workflow current_version

Revision ID: a1b2c3d4e5f6
Revises: 21d074a0eb86
Create Date: 2026-07-16 12:00:00.000000

"""
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f6'
down_revision: str | None = '21d074a0eb86'
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column('workflows', sa.Column('current_version', sa.Integer(), nullable=True))


def downgrade() -> None:
    op.drop_column('workflows', 'current_version')
