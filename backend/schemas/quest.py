from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from models.quest import Difficulty

class QuestBase(BaseModel):
    title: str
    description: Optional[str] = None
    category: str = "General"
    difficulty: Difficulty = Difficulty.MEDIUM
    xp_reward: int = 50
    coin_reward: int = 10
    due_date: Optional[datetime] = None
    is_recurring: bool = False
    recurring_schedule: Optional[str] = None

class QuestCreate(QuestBase):
    pass

class QuestUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    difficulty: Optional[Difficulty] = None
    xp_reward: Optional[int] = None
    coin_reward: Optional[int] = None
    due_date: Optional[datetime] = None
    is_completed: Optional[bool] = None
    is_recurring: Optional[bool] = None
    recurring_schedule: Optional[str] = None

class QuestResponse(QuestBase):
    id: int
    user_id: int
    is_completed: bool
    created_at: datetime
    completed_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
