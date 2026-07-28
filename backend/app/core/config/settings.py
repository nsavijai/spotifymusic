from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = 'VMusic API'
    app_version: str = '1.0.0'
    debug: bool = True
    api_v1_prefix: str = '/api/v1'
    allowed_origins: list[str] = ['*']

    database_url: str = 'sqlite+aiosqlite:///./vmusic.db'
    redis_url: str = 'redis://localhost:6379/0'

    jwt_secret_key: str = 'change-me-in-production'
    jwt_algorithm: str = 'HS256'
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    # Audius
    audius_api_base: str = 'https://discoveryprovider.audius.co/v1'
    audius_app_name: str = 'VMusic'
    audius_cache_ttl_seconds: int = 300  # 5 minutes

    model_config = SettingsConfigDict(env_file='.env', extra='ignore')


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
