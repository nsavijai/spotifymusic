from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta, timezone
from app.core.config.settings import settings
from app.features.authentication.models.refresh_token import RefreshToken

class RefreshTokenRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def create(self, user_id: int) -> RefreshToken:
        expires_at = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=settings.refresh_token_expire_days)
        token_str = __import__('secrets').token_urlsafe(32)
        token = RefreshToken(
            token=token_str,
            user_id=user_id,
            expires_at=expires_at,
            revoked=False,
        )
        self.session.add(token)
        await self.session.commit()
        await self.session.refresh(token)
        return token

    async def get_by_token(self, token_str: str) -> RefreshToken | None:
        result = await self.session.execute(
            select(RefreshToken).where(RefreshToken.token == token_str)
        )
        return result.scalar_one_or_none()

    async def revoke(self, token: RefreshToken) -> None:
        token.revoked = True
        self.session.add(token)
        await self.session.commit()

    async def revoke_user_tokens(self, user_id: int) -> None:
        now = datetime.now(timezone.utc).replace(tzinfo=None)
        await self.session.execute(
            delete(RefreshToken).where(
                RefreshToken.user_id == user_id,
                RefreshToken.revoked == False,
                RefreshToken.expires_at > now,
            )
        )
        await self.session.commit()
