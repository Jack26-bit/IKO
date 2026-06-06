from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone

from database.database import get_db
from models.quest import Quest
from models.user import User
from schemas.quest import QuestCreate, QuestResponse, QuestUpdate
from services.rpg_engine import add_xp_to_user, add_coins, update_streak
from api.deps import get_current_user


router = APIRouter()

@router.get("/", response_model=List[QuestResponse])
def get_quests(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    quests = db.query(Quest).filter(Quest.user_id == current_user.id).all()
    return quests

@router.post("/", response_model=QuestResponse)
def create_quest(quest_in: QuestCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    quest = Quest(**quest_in.model_dump(), user_id=current_user.id)
    db.add(quest)
    db.commit()
    db.refresh(quest)
    return quest

@router.patch("/{quest_id}/complete")
def complete_quest(quest_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    quest = db.query(Quest).filter(Quest.id == quest_id, Quest.user_id == current_user.id).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
        
    if quest.is_completed:
        raise HTTPException(status_code=400, detail="Quest is already completed")
        
    quest.is_completed = True
    quest.completed_at = datetime.now(timezone.utc)
    
    # Trigger RPG Engine
    rpg_result = add_xp_to_user(db, current_user, quest.xp_reward)
    add_coins(db, current_user, quest.coin_reward)
    update_streak(db, current_user)

    
    db.commit()
    db.refresh(quest)
    
    return {
        "message": "Quest completed",
        "quest": quest,
        "rpg_updates": rpg_result
    }

@router.delete("/{quest_id}")
def delete_quest(quest_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    quest = db.query(Quest).filter(Quest.id == quest_id, Quest.user_id == current_user.id).first()
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
        
    db.delete(quest)
    db.commit()
    return {"message": "Quest deleted successfully"}
