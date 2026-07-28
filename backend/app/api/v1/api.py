from fastapi import APIRouter

from app.features.authentication.api.auth_routes import router as auth_router
from app.features.music.api.songs_routes import router as songs_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(songs_router)
