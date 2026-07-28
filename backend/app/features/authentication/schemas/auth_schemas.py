from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    email: EmailStr
    username: str = Field(min_length=3, max_length=50)
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1)


class RefreshRequest(BaseModel):
    refresh_token: str


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8, max_length=128)


class UpdateProfileRequest(BaseModel):
    name: str | None = Field(None, max_length=150)
    bio: str | None = Field(None, max_length=500)
    avatar_url: str | None = None


class UserResponse(BaseModel):
    id: str
    email: str
    username: str
    name: str
    avatar_url: str
    is_premium: bool
    followers_count: int
    following_count: int
    bio: str
    is_active: bool

    model_config = {'from_attributes': True}


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = 'bearer'
    user: UserResponse
