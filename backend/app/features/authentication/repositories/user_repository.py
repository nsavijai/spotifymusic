from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.features.authentication.models.user import User


class UserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_email(self, email: str) -> User | None:
        result = await self.session.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def get_by_username(self, username: str) -> User | None:
        result = await self.session.execute(select(User).where(User.username == username))
        return result.scalar_one_or_none()

    async def get_by_id(self, user_id: int) -> User | None:
        result = await self.session.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()

    async def create(
        self,
        *,
        email: str,
        username: str,
        name: str,
        hashed_password: str,
    ) -> User:
        user = User(
            email=email,
            username=username,
            name=name,
            hashed_password=hashed_password,
        )
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user

    async def update(self, user: User, **kwargs: object) -> User:
        for attr, value in kwargs.items():
            setattr(user, attr, value)
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user

    async def set_password(self, user: User, new_hashed_password: str) -> User:
        user.hashed_password = new_hashed_password
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user
