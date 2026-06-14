from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone

from database.database import get_db
from models.quest import Quest, Difficulty
from models.user import User
from schemas.quest import QuestCreate, QuestResponse, QuestUpdate
from services.rpg_engine import add_xp_to_user, add_coins, update_streak


router = APIRouter()


# Mock single-user auth for local-first usage. Production deployments should
# replace this with a proper JWT/Auth flow.
def get_current_user(db: Session = Depends(get_db)) -> User:
    user = db.query(User).first()
    if not user:
        user = User(email="you@iko.local", username="Wanderer", hashed_password="local")
        db.add(user)
        db.commit()
        db.refresh(user)
    return user


@router.get("/", response_model=List[QuestResponse])
def list_quests(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Quest).filter(Quest.user_id == current_user.id).order_by(Quest.created_at.desc()).all()


@router.post("/", response_model=QuestResponse)
def create_quest(
    quest_in: QuestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    quest = Quest(**quest_in.model_dump(), user_id=current_user.id)
    db.add(quest)
    db.commit()
    db.refresh(quest)
    return quest


@router.patch("/{quest_id}", response_model=QuestResponse)
def update_quest(
    quest_id: int,
    quest_in: QuestUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    quest = db.query(Quest).filter(Quest.id == quest_id, Quest.user_id == current_user.id).first()
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")

    payload = quest_in.model_dump(exclude_unset=True)
    # Coerce string difficulty -> Difficulty enum if provided as raw string.
    if "difficulty" in payload and isinstance(payload["difficulty"], str):
        try:
            payload["difficulty"] = Difficulty(payload["difficulty"].lower())
        except ValueError:
            payload.pop("difficulty")

    for field, value in payload.items():
        setattr(quest, field, value)

    db.commit()
    db.refresh(quest)
    return quest


@router.patch("/{quest_id}/complete")
def complete_quest(
    quest_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    quest = db.query(Quest).filter(Quest.id == quest_id, Quest.user_id == current_user.id).first()
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    if quest.is_completed:
        raise HTTPException(status_code=400, detail="Quest is already completed")

    quest.is_completed = True
    quest.completed_at = datetime.now(timezone.utc)

    rpg_result = add_xp_to_user(db, current_user, quest.xp_reward)
    add_coins(db, current_user, quest.coin_reward)
    update_streak(db, current_user)

    db.commit()
    db.refresh(quest)

    return {
        "message": "Quest completed",
        "quest": QuestResponse.model_validate(quest).model_dump(mode="json"),
        "rpg_updates": rpg_result,
    }


@router.delete("/{quest_id}")
def delete_quest(
    quest_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    quest = db.query(Quest).filter(Quest.id == quest_id, Quest.user_id == current_user.id).first()
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    db.delete(quest)
    db.commit()
    return {"message": "Quest deleted successfully"}
