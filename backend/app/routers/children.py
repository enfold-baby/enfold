from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user, require_family_id
from app.db import get_db
from app.models import Child, User
from app.schemas import ChildCreate, ChildResponse

router = APIRouter(prefix="/v1/children", tags=["children"])


@router.get("", response_model=list[ChildResponse])
async def list_children(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)) -> list[Child]:
    family_id = await require_family_id(user, db)
    rows = await db.execute(select(Child).where(Child.family_id == family_id).order_by(Child.created_at))
    return list(rows.scalars().all())


@router.post("", response_model=ChildResponse)
async def create_child(
    payload: ChildCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Child:
    family_id = await require_family_id(user, db)
    child = Child(family_id=family_id, name=payload.name, birth_date=payload.birth_date)
    db.add(child)
    await db.commit()
    await db.refresh(child)
    return child
