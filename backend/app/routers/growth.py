import uuid

from fastapi import APIRouter, Depends, HTTPException, Path, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import get_current_user, require_family_id
from app.db import get_db
from app.models import Child, GrowthMeasurement, MilestoneAchievement, User
from app.schemas import (
    GrowthMeasurementResponse,
    GrowthMeasurementUpsert,
    MilestoneResponse,
    MilestoneUpsert,
)

# Growth measurements and milestones shared across the family. Writes are
# idempotent PUTs keyed by what the phone already knows (measurement id,
# child + milestone key), so a retried sync never duplicates a row.
router = APIRouter(prefix="/v1", tags=["growth"])

_MILESTONE_KEY = Path(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_.\-]+$")


async def _assert_child_access(db: AsyncSession, child_id: uuid.UUID, family_id: uuid.UUID) -> Child:
    child = (
        await db.execute(select(Child).where(Child.id == child_id, Child.family_id == family_id))
    ).scalar_one_or_none()
    if child is None:
        raise HTTPException(status_code=404, detail="Child not found")
    return child


@router.get("/growth-measurements", response_model=list[GrowthMeasurementResponse])
async def list_growth_measurements(
    child_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[GrowthMeasurement]:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, child_id, family_id)
    rows = await db.execute(
        select(GrowthMeasurement)
        .where(GrowthMeasurement.child_id == child_id, GrowthMeasurement.family_id == family_id)
        .order_by(GrowthMeasurement.measured_at.desc())
    )
    return list(rows.scalars().all())


@router.put("/growth-measurements/{measurement_id}", response_model=GrowthMeasurementResponse)
async def upsert_growth_measurement(
    measurement_id: uuid.UUID,
    payload: GrowthMeasurementUpsert,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> GrowthMeasurement:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, payload.child_id, family_id)

    row = await db.get(GrowthMeasurement, measurement_id)
    if row is not None and row.family_id != family_id:
        raise HTTPException(status_code=404, detail="Growth measurement not found")
    if row is None:
        row = GrowthMeasurement(
            id=measurement_id,
            family_id=family_id,
            created_by_user_id=user.id,
        )
        db.add(row)

    row.child_id = payload.child_id
    row.measured_at = payload.measured_at
    row.weight_kg = payload.weight_kg
    row.length_cm = payload.length_cm
    row.head_cm = payload.head_cm
    row.note = payload.note

    await db.commit()
    await db.refresh(row)
    return row


@router.delete("/growth-measurements/{measurement_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_growth_measurement(
    measurement_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Response:
    family_id = await require_family_id(user, db)
    row = await db.get(GrowthMeasurement, measurement_id)
    if row is None or row.family_id != family_id:
        raise HTTPException(status_code=404, detail="Growth measurement not found")
    await db.delete(row)
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/milestones", response_model=list[MilestoneResponse])
async def list_milestones(
    child_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[MilestoneAchievement]:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, child_id, family_id)
    rows = await db.execute(
        select(MilestoneAchievement)
        .where(MilestoneAchievement.child_id == child_id, MilestoneAchievement.family_id == family_id)
        .order_by(MilestoneAchievement.achieved_at.desc())
    )
    return list(rows.scalars().all())


async def _get_milestone(
    db: AsyncSession, child_id: uuid.UUID, milestone_key: str
) -> MilestoneAchievement | None:
    return (
        await db.execute(
            select(MilestoneAchievement).where(
                MilestoneAchievement.child_id == child_id,
                MilestoneAchievement.milestone_key == milestone_key,
            )
        )
    ).scalar_one_or_none()


@router.put("/milestones/{child_id}/{milestone_key}", response_model=MilestoneResponse)
async def upsert_milestone(
    child_id: uuid.UUID,
    payload: MilestoneUpsert,
    milestone_key: str = _MILESTONE_KEY,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> MilestoneAchievement:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, child_id, family_id)

    row = await _get_milestone(db, child_id, milestone_key)
    if row is None:
        row = MilestoneAchievement(
            child_id=child_id,
            family_id=family_id,
            milestone_key=milestone_key,
            created_by_user_id=user.id,
        )
        db.add(row)
    row.achieved_at = payload.achieved_at
    row.note = payload.note

    await db.commit()
    await db.refresh(row)
    return row


@router.delete("/milestones/{child_id}/{milestone_key}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_milestone(
    child_id: uuid.UUID,
    milestone_key: str = _MILESTONE_KEY,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Response:
    family_id = await require_family_id(user, db)
    await _assert_child_access(db, child_id, family_id)
    row = await _get_milestone(db, child_id, milestone_key)
    if row is None:
        raise HTTPException(status_code=404, detail="Milestone not found")
    await db.delete(row)
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
