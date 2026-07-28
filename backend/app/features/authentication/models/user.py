from sqlalchemy import Boolean, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database.base import Base


class User(Base):
    __tablename__ = 'users'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    username: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(150), nullable=False, default='')
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    avatar_url: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
        default='https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
    )
    bio: Mapped[str] = mapped_column(Text, nullable=False, default='')
    is_premium: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    followers_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    following_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
