from sqlalchemy.orm import Session
from models.user import User
import math

def calculate_xp_for_level(level: int) -> int:
    """
    Returns the total XP required to REACH the next level.
    e.g. Level 1 to 2 requires 100 XP.
    Level 2 to 3 requires 200 XP.
    """
    return level * 100

def add_xp_to_user(db: Session, user: User, xp_gained: int) -> dict:
    """
    Adds XP to a user and handles leveling up.
    Returns a dict with level_up status and new stats.
    """
    user.xp += xp_gained
    leveled_up = False
    levels_gained = 0

    xp_needed = calculate_xp_for_level(user.level)
    
    while user.xp >= xp_needed:
        # Level up!
        user.xp -= xp_needed
        user.level += 1
        levels_gained += 1
        leveled_up = True
        # Calculate next level requirement
        xp_needed = calculate_xp_for_level(user.level)

    db.commit()
    db.refresh(user)
    
    return {
        "leveled_up": leveled_up,
        "levels_gained": levels_gained,
        "new_level": user.level,
        "current_xp": user.xp,
        "xp_needed": calculate_xp_for_level(user.level)
    }

def add_coins(db: Session, user: User, coins_gained: int):
    user.coins += coins_gained
    db.commit()
    db.refresh(user)

from datetime import datetime, timezone

def update_streak(db: Session, user: User):
    now = datetime.now(timezone.utc)
    
    if not user.last_active_date:
        user.current_streak = 1
        user.longest_streak = 1
        user.last_active_date = now
    else:
        delta_days = (now.date() - user.last_active_date.date()).days
        
        if delta_days == 1:
            # Completed a quest the next day
            user.current_streak += 1
            if user.current_streak > user.longest_streak:
                user.longest_streak = user.current_streak
            user.last_active_date = now
        elif delta_days > 1:
            # Missed a day
            user.current_streak = 1
            user.last_active_date = now
        # If delta_days == 0, it means they already completed a quest today, streak doesn't increment but stays active.

    db.commit()
    db.refresh(user)

