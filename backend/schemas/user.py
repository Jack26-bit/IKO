from pydantic import BaseModel, ConfigDict, EmailStr
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    username: str

class UserCreate(UserBase):
    password: str

class UserAvatarUpdate(BaseModel):
    avatar_url: str


class UserResponse(UserBase):
    id: int
    level: int
    xp: int
    coins: int
    rpg_class: str
    current_streak: int
    longest_streak: int
    avatar_url: Optional[str] = None
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
