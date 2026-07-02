from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ...core.database import get_db
from ...models.user import User, Profile
from ...schemas.coding import LeaderboardEntryResponse
from ..deps import get_current_user

router = APIRouter()

def _get_sorted_leaderboard(db: Session, current_user_id: int) -> List[LeaderboardEntryResponse]:
    # Query all profile databases and order by XP
    profiles = db.query(Profile).order_by(Profile.xp.desc()).all()
    
    response = []
    # Seed mock leaders static list if DB profiles is small
    mock_leaders = [
        {"name": "Siddharth M.", "xp": 3450, "avatar": "🦊"},
        {"name": "Priyanjali S.", "xp": 2900, "avatar": "🦁"},
        {"name": "Rohan Gupta", "xp": 2100, "avatar": "🐯"},
        {"name": "Amit Kumar", "xp": 1200, "avatar": "🐻"},
        {"name": "Nisha R.", "xp": 950, "avatar": "🐼"},
    ]

    # Find the current user profile
    my_profile = db.query(Profile).filter(Profile.user_id == current_user_id).first()
    my_xp = my_profile.xp if my_profile else 0
    my_name = my_profile.name if my_profile else "You"

    # Merge my details with mock leaders
    all_players = []
    for item in mock_leaders:
        all_players.append({"name": item["name"], "xp": item["xp"], "avatar": item["avatar"], "is_me": False})
    
    # Check if I am already present, if not add
    all_players.append({"name": my_name, "xp": my_xp, "avatar": "⚡", "is_me": True})

    # Sort
    all_players.sort(key=lambda x: x["xp"], reverse=True)

    for i, p in enumerate(all_players):
        response.append(LeaderboardEntryResponse(
            rank=i + 1,
            name=p["name"],
            xp=p["xp"],
            avatar=p["avatar"],
            is_me=p["is_me"]
        ))
    return response

@router.get("/weekly", response_model=List[LeaderboardEntryResponse])
def get_weekly_leaderboard(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return _get_sorted_leaderboard(db, current_user.id)

@router.get("/monthly", response_model=List[LeaderboardEntryResponse])
def get_monthly_leaderboard(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Simply shift metrics offset for monthly ranking visual variance
    res = _get_sorted_leaderboard(db, current_user.id)
    monthly_res = []
    for entry in res:
        monthly_res.append(LeaderboardEntryResponse(
            rank=entry.rank,
            name=entry.name,
            xp=entry.xp * 4 + 800,
            avatar=entry.avatar,
            is_me=entry.is_me
        ))
    monthly_res.sort(key=lambda x: x.xp, reverse=True)
    
    # Recalculate ranks
    final_res = []
    for i, item in enumerate(monthly_res):
        final_res.append(LeaderboardEntryResponse(
            rank=i + 1,
            name=item.name,
            xp=item.xp,
            avatar=item.avatar,
            is_me=item.is_me
        ))
    return final_res

@router.get("/friends", response_model=List[LeaderboardEntryResponse])
def get_friends_leaderboard(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Friends contains a subset of rankings
    res = _get_sorted_leaderboard(db, current_user.id)
    friends_res = [entry for entry in res if entry.name in ["You", "Rohan Gupta", "Nisha R."]]
    
    # Recalculate ranks
    final_res = []
    for i, item in enumerate(friends_res):
        final_res.append(LeaderboardEntryResponse(
            rank=i + 1,
            name=item.name,
            xp=item.xp,
            avatar=item.avatar,
            is_me=item.is_me
        ))
    return final_res
