from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from database.database import Base

class Difficulty(enum.Enum):
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"
    EPIC = "epic"

class Quest(Base):
    __tablename__ = "quests"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    category = Column(String, default="General")
    difficulty = Column(Enum(Difficulty), default=Difficulty.MEDIUM)
    
    xp_reward = Column(Integer, default=50)
    coin_reward = Column(Integer, default=10)
    
    due_date = Column(DateTime(timezone=True), nullable=True)
    is_completed = Column(Boolean, default=False)
    is_recurring = Column(Boolean, default=False)
    recurring_schedule = Column(String, nullable=True) # e.g., "daily", "weekly"
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)
