from passlib.context import CryptContext

from app.core.exceptions.http_exceptions import UnauthorizedException, ValidationException
from app.core.security.jwt_handler import create_access_token, create_refresh_token
from app.features.authentication.models.user import User
from app.features.authentication.repositories.refresh_token_repository import RefreshTokenRepository
from app.features.authentication.repositories.user_repository import UserRepository
from app.features.authentication.schemas.auth_schemas import UserResponse

pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')


def _user_response(user: User) -> UserResponse:
    return UserResponse(
        id=str(user.id),
        email=user.email,
        username=user.username,
        name=user.name or user.username,
        avatar_url=user.avatar_url,
        bio=user.bio,
        is_premium=user.is_premium,
        is_active=user.is_active,
        followers_count=user.followers_count,
        following_count=user.following_count,
    )


class AuthService:
    def __init__(
        self,
        user_repo: UserRepository,
        token_repo: RefreshTokenRepository,
    ) -> None:
        self.user_repo = user_repo
        self.token_repo = token_repo

    async def register(self, *, email: str, username: str, password: str) -> dict:
        if await self.user_repo.get_by_email(email):
            raise ValidationException('A user with this email already exists', 'email_taken')
        if await self.user_repo.get_by_username(username):
            raise ValidationException('This username is already taken', 'username_taken')

        hashed = pwd_context.hash(password)
        user = await self.user_repo.create(
            email=email,
            username=username,
            name=username,
            hashed_password=hashed,
        )
        access = create_access_token(str(user.id))
        refresh_obj = await self.token_repo.create(user.id)
        return {
            'access_token': access,
            'refresh_token': refresh_obj.token,
            'token_type': 'bearer',
            'user': _user_response(user).model_dump(),
        }

    async def login(self, *, email: str, password: str) -> dict:
        user = await self.user_repo.get_by_email(email)
        if user is None or not pwd_context.verify(password, user.hashed_password):
            raise UnauthorizedException('Invalid email or password', 'invalid_credentials')
        if not user.is_active:
            raise UnauthorizedException('Account is deactivated', 'account_inactive')

        access = create_access_token(str(user.id))
        refresh_obj = await self.token_repo.create(user.id)
        return {
            'access_token': access,
            'refresh_token': refresh_obj.token,
            'token_type': 'bearer',
            'user': _user_response(user).model_dump(),
        }

    async def refresh(self, *, refresh_token: str) -> dict:
        token_obj = await self.token_repo.get_by_token(refresh_token)
        if token_obj is None or token_obj.revoked:
            raise UnauthorizedException('Invalid or expired refresh token', 'invalid_refresh_token')

        from datetime import datetime, timezone
        if token_obj.expires_at < datetime.now(timezone.utc).replace(tzinfo=None):
            raise UnauthorizedException('Refresh token expired', 'refresh_token_expired')

        await self.token_repo.revoke(token_obj)
        user = await self.user_repo.get_by_id(token_obj.user_id)
        if user is None or not user.is_active:
            raise UnauthorizedException('User not found', 'user_not_found')

        access = create_access_token(str(user.id))
        new_refresh = await self.token_repo.create(user.id)
        return {
            'access_token': access,
            'refresh_token': new_refresh.token,
            'token_type': 'bearer',
        }

    async def logout(self, *, user_id: int) -> None:
        await self.token_repo.revoke_user_tokens(user_id)

    async def get_me(self, *, user_id: int) -> UserResponse:
        user = await self.user_repo.get_by_id(user_id)
        if user is None:
            raise UnauthorizedException('User not found', 'user_not_found')
        return _user_response(user)

    async def update_profile(
        self,
        *,
        user_id: int,
        name: str | None,
        bio: str | None,
        avatar_url: str | None,
    ) -> UserResponse:
        user = await self.user_repo.get_by_id(user_id)
        if user is None:
            raise UnauthorizedException('User not found', 'user_not_found')
        updates: dict = {}
        if name is not None:
            updates['name'] = name
        if bio is not None:
            updates['bio'] = bio
        if avatar_url is not None:
            updates['avatar_url'] = avatar_url
        if updates:
            user = await self.user_repo.update(user, **updates)
        return _user_response(user)

    async def change_password(
        self,
        *,
        user_id: int,
        current_password: str,
        new_password: str,
    ) -> None:
        user = await self.user_repo.get_by_id(user_id)
        if user is None:
            raise UnauthorizedException('User not found', 'user_not_found')
        if not pwd_context.verify(current_password, user.hashed_password):
            raise UnauthorizedException('Current password is incorrect', 'wrong_password')
        new_hashed = pwd_context.hash(new_password)
        await self.user_repo.set_password(user, new_hashed)
        await self.token_repo.revoke_user_tokens(user_id)
