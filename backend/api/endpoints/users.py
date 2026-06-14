from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database.database import get_db
from models.user import User
from schemas.user import UserAvatarUpdate, UserResponse

router = APIRouter()


def get_current_user(db: Session = Depends(get_db)) -> User:
    user = db.query(User).first()
    if not user:
        user = User(email="you@iko.local", username="Wanderer", hashed_password="local")
        db.add(user)
        db.commit()
        db.refresh(user)
    return user


class UsernameUpdate(BaseModel):
    username: str


@router.get("/me", response_model=UserResponse)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    return current_user


@router.patch("/me", response_model=UserResponse)
def update_username(
    payload: UsernameUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    name = payload.username.strip()
    if name:
        current_user.username = name
        db.commit()
        db.refresh(current_user)
    return current_user


@router.patch("/me/avatar", response_model=UserResponse)
def update_avatar(
    avatar_data: UserAvatarUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    current_user.avatar_url = avatar_data.avatar_url
    db.commit()
    db.refresh(current_user)
    return current_user
