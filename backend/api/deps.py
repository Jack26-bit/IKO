from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session

from database.database import get_db
from models.user import User


def get_current_user(
    db: Session = Depends(get_db),
    x_user_id: int | None = Header(default=None, alias="X-User-Id"),
) -> User:
    if x_user_id is not None:
        user = db.query(User).filter(User.id == x_user_id).first()
        if user:
            return user
        raise HTTPException(status_code=401, detail="Invalid user session")

    user = db.query(User).first()
    if not user:
        user = User(
            email="test@example.com",
            username="PlayerOne",
            hashed_password="hashed",
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    return user
