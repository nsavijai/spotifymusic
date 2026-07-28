"""
Authentication routes
=====================
All endpoints return the envelope: { success, message, data }
Flutter's AuthRepository expects this exact shape.
"""
from __future__ import annotations

from fastapi import APIRouter, Body, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database.session import get_db_session
from app.core.dependencies.auth import get_current_user
from app.core.exceptions.http_exceptions import ApiException
from app.features.authentication.repositories.refresh_token_repository import RefreshTokenRepository
from app.features.authentication.repositories.user_repository import UserRepository
from app.features.authentication.schemas.auth_schemas import (
    ChangePasswordRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    UpdateProfileRequest,
)
from app.features.authentication.services.auth_service import AuthService

router = APIRouter(tags=['authentication'])


def _ok(data: object = None, message: str = 'Success') -> dict:
    return {'success': True, 'message': message, 'data': data if data is not None else {}}


def _get_service(session: AsyncSession) -> AuthService:
    return AuthService(
        user_repo=UserRepository(session),
        token_repo=RefreshTokenRepository(session),
    )


# ─── Register ─────────────────────────────────────────────────────────────────

@router.post('/auth/register', status_code=status.HTTP_201_CREATED)
async def register(
    body: RegisterRequest,
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    try:
        data = await _get_service(session).register(
            email=body.email,
            username=body.username,
            password=body.password,
        )
        return _ok(data, 'User registered successfully')
    except ApiException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail={'message': str(exc)}) from exc


# ─── Login ────────────────────────────────────────────────────────────────────

@router.post('/auth/login')
async def login(
    body: LoginRequest,
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    try:
        data = await _get_service(session).login(email=body.email, password=body.password)
        return _ok(data, 'Login successful')
    except ApiException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail={'message': str(exc)}) from exc


# ─── Refresh ──────────────────────────────────────────────────────────────────

@router.post('/auth/refresh')
async def refresh(
    body: RefreshRequest,
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    try:
        data = await _get_service(session).refresh(refresh_token=body.refresh_token)
        return _ok(data, 'Token refreshed successfully')
    except ApiException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail={'message': str(exc)}) from exc


# ─── Logout ───────────────────────────────────────────────────────────────────

@router.post('/auth/logout')
async def logout(
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    try:
        user_id = int(current_user['sub'])
        await _get_service(session).logout(user_id=user_id)
    except Exception:
        pass  # Always succeed on logout
    return _ok(message='Logged out successfully')


# ─── Current User ─────────────────────────────────────────────────────────────

@router.get('/users/me')
async def get_me(
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    user_id = int(current_user['sub'])
    user = await _get_service(session).get_me(user_id=user_id)
    return _ok(user.model_dump(), 'Current user profile')


# ─── Update Profile ───────────────────────────────────────────────────────────

@router.put('/users/me')
async def update_me(
    body: UpdateProfileRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    user_id = int(current_user['sub'])
    user = await _get_service(session).update_profile(
        user_id=user_id,
        name=body.name,
        bio=body.bio,
        avatar_url=body.avatar_url,
    )
    return _ok(user.model_dump(), 'Profile updated successfully')


# ─── Change Password ──────────────────────────────────────────────────────────

@router.post('/auth/change-password')
async def change_password(
    body: ChangePasswordRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    user_id = int(current_user['sub'])
    await _get_service(session).change_password(
        user_id=user_id,
        current_password=body.current_password,
        new_password=body.new_password,
    )
    return _ok(message='Password changed successfully')
