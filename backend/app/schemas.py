import uuid
from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field


class MagicCodeRequest(BaseModel):
    email: EmailStr


class MagicCodeVerify(BaseModel):
    email: EmailStr
    code: str = Field(min_length=4, max_length=12)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: uuid.UUID
    email: EmailStr
    display_name: str


class MeResponse(BaseModel):
    user: UserResponse


class UserProfileUpdate(BaseModel):
    display_name: str = Field(default="", max_length=120)


class ChildCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    birth_date: date | None = None


class ChildResponse(BaseModel):
    id: uuid.UUID
    family_id: uuid.UUID
    name: str
    birth_date: date | None
    created_at: datetime


class CareEventCreate(BaseModel):
    id: uuid.UUID | None = None
    child_id: uuid.UUID
    type: str = Field(pattern="^(feeding|diaper|sleep|pumping|medication|note)$")
    occurred_at: datetime
    details: dict = Field(default_factory=dict)
    note: str = ""
    client_updated_at: datetime | None = None


class CareEventUpdate(BaseModel):
    type: str | None = Field(
        default=None,
        pattern="^(feeding|diaper|sleep|pumping|medication|note)$",
    )
    occurred_at: datetime | None = None
    details: dict | None = None
    note: str | None = None
    client_updated_at: datetime | None = None


class CareEventResponse(BaseModel):
    id: uuid.UUID
    child_id: uuid.UUID
    family_id: uuid.UUID
    type: str
    occurred_at: datetime
    details: dict
    note: str
    created_by_user_id: uuid.UUID | None = None
    created_by_display_name: str = ""
    created_at: datetime
    updated_at: datetime


class GrowthMeasurementUpsert(BaseModel):
    child_id: uuid.UUID
    measured_at: datetime
    weight_kg: float | None = Field(default=None, gt=0, le=100)
    length_cm: float | None = Field(default=None, gt=0, le=250)
    head_cm: float | None = Field(default=None, gt=0, le=100)
    note: str = Field(default="", max_length=2000)


class GrowthMeasurementResponse(BaseModel):
    id: uuid.UUID
    child_id: uuid.UUID
    measured_at: datetime
    weight_kg: float | None
    length_cm: float | None
    head_cm: float | None
    note: str
    updated_at: datetime


class MilestoneUpsert(BaseModel):
    achieved_at: datetime
    note: str = Field(default="", max_length=2000)


class MilestoneResponse(BaseModel):
    child_id: uuid.UUID
    milestone_key: str
    achieved_at: datetime
    note: str
    updated_at: datetime


class DeviceRegister(BaseModel):
    platform: str = Field(min_length=1, max_length=32)
    fcm_token: str = Field(min_length=1)


class DeviceUnregister(BaseModel):
    fcm_token: str = Field(min_length=1)


class BetaRequestCreate(BaseModel):
    email: EmailStr
    name: str = Field(default="", max_length=120)
    platform: str = Field(default="android", max_length=32)
    message: str = Field(default="", max_length=1000)
    # Honeypot — bots fill this; humans leave it empty.
    website: str = Field(default="", max_length=200)


class BetaRequestResponse(BaseModel):
    status: str = "sent"


class FamilyMemberResponse(BaseModel):
    id: uuid.UUID
    email: EmailStr
    display_name: str


class FamilyInfoResponse(BaseModel):
    id: uuid.UUID
    invite_code: str | None = None
    members: list[FamilyMemberResponse]


class FamilyInviteResponse(BaseModel):
    code: str
    expires_at: datetime | None = None


class FamilyJoinRequest(BaseModel):
    code: str = Field(min_length=4, max_length=32)