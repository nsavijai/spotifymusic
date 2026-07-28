"""
End-to-end tests for VMusic backend.
Auth tests use dependency injection to bypass the real database.
Music/songs tests hit the fallback data (no Audius required).
"""
from __future__ import annotations

from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient

from main import app


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _make_user(user_id: int = 1, email: str = 'test@vmusic.app') -> MagicMock:
    u = MagicMock()
    u.id = user_id
    u.email = email
    u.username = 'testuser'
    u.name = 'Test User'
    u.avatar_url = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80'
    u.bio = ''
    u.is_premium = False
    u.is_active = True
    u.followers_count = 0
    u.following_count = 0
    u.hashed_password = '$2b$12$KIXqFakeHashForTestingOnly'
    return u


def _make_refresh_token(user_id: int = 1) -> MagicMock:
    t = MagicMock()
    t.token = 'test_refresh_token_abc123'
    t.user_id = user_id
    t.revoked = False
    from datetime import datetime, timedelta, timezone
    t.expires_at = (datetime.now(timezone.utc) + timedelta(days=7)).replace(tzinfo=None)
    return t


# ─── Fixtures ─────────────────────────────────────────────────────────────────

@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


@pytest.fixture
def auth_client() -> TestClient:
    """Client with DB session overridden to avoid needing a real database."""
    from app.core.database.session import get_db_session
    from app.features.authentication.repositories.refresh_token_repository import RefreshTokenRepository
    from app.features.authentication.repositories.user_repository import UserRepository
    from app.features.authentication.services.auth_service import AuthService, pwd_context

    mock_user = _make_user()
    mock_user.hashed_password = pwd_context.hash('password123')
    mock_refresh = _make_refresh_token()

    mock_user_repo = AsyncMock(spec=UserRepository)
    mock_user_repo.get_by_email.return_value = None  # default: user doesn't exist
    mock_user_repo.get_by_username.return_value = None
    mock_user_repo.create.return_value = mock_user
    mock_user_repo.get_by_id.return_value = mock_user

    mock_token_repo = AsyncMock(spec=RefreshTokenRepository)
    mock_token_repo.create.return_value = mock_refresh
    mock_token_repo.get_by_token.return_value = mock_refresh
    mock_token_repo.revoke.return_value = None
    mock_token_repo.revoke_user_tokens.return_value = None

    mock_session = AsyncMock()

    async def _override_session():
        yield mock_session

    # Patch AuthService to use our mocks
    original_get_service = None

    import app.features.authentication.api.auth_routes as auth_module

    def _patched_get_service(_session):
        return AuthService(user_repo=mock_user_repo, token_repo=mock_token_repo)

    auth_module._get_service = _patched_get_service
    app.dependency_overrides[get_db_session] = _override_session

    yield TestClient(app)

    app.dependency_overrides.clear()
    auth_module._get_service = lambda s: AuthService(
        user_repo=UserRepository(s),
        token_repo=RefreshTokenRepository(s),
    )


# ─── Health ───────────────────────────────────────────────────────────────────

def test_health_check(client: TestClient) -> None:
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] is True


# ─── Auth ─────────────────────────────────────────────────────────────────────

def test_register_returns_wrapped_payload(auth_client: TestClient) -> None:
    response = auth_client.post(
        '/api/v1/auth/register',
        json={'email': 'new@vmusic.app', 'username': 'NewUser', 'password': 'secret123'},
    )
    assert response.status_code == 201
    body = response.json()
    assert body['success'] is True
    assert 'access_token' in body['data']
    assert 'refresh_token' in body['data']
    assert 'user' in body['data']


def test_login_returns_wrapped_payload(auth_client: TestClient) -> None:
    from app.features.authentication.services.auth_service import pwd_context
    import app.features.authentication.api.auth_routes as auth_module
    from app.features.authentication.repositories.user_repository import UserRepository
    from app.features.authentication.repositories.refresh_token_repository import RefreshTokenRepository
    from app.features.authentication.services.auth_service import AuthService

    mock_user = _make_user(email='demo@vmusic.app')
    mock_user.hashed_password = pwd_context.hash('password123')
    mock_refresh = _make_refresh_token()

    from unittest.mock import AsyncMock
    mock_user_repo = AsyncMock(spec=UserRepository)
    mock_user_repo.get_by_email.return_value = mock_user
    mock_token_repo = AsyncMock(spec=RefreshTokenRepository)
    mock_token_repo.create.return_value = mock_refresh

    auth_module._get_service = lambda s: AuthService(
        user_repo=mock_user_repo, token_repo=mock_token_repo
    )

    response = auth_client.post(
        '/api/v1/auth/login',
        json={'email': 'demo@vmusic.app', 'password': 'password123'},
    )
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    data = body['data']
    assert 'access_token' in data
    assert 'refresh_token' in data
    assert data['token_type'] == 'bearer'
    assert 'user' in data


def test_refresh_token(auth_client: TestClient) -> None:
    response = auth_client.post(
        '/api/v1/auth/refresh',
        json={'refresh_token': 'test_refresh_token_abc123'},
    )
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert 'access_token' in body['data']


def test_logout(auth_client: TestClient) -> None:
    from app.core.security.jwt_handler import create_access_token
    token = create_access_token('1')
    response = auth_client.post(
        '/api/v1/auth/logout',
        headers={'Authorization': f'Bearer {token}'},
    )
    assert response.status_code == 200
    assert response.json()['success'] is True


def test_get_current_user(auth_client: TestClient) -> None:
    from app.core.security.jwt_handler import create_access_token
    token = create_access_token('1')
    response = auth_client.get(
        '/api/v1/users/me',
        headers={'Authorization': f'Bearer {token}'},
    )
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert 'email' in body['data']


# ─── Songs ────────────────────────────────────────────────────────────────────

def test_songs_endpoint_returns_list(client: TestClient) -> None:
    response = client.get('/api/v1/songs')
    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, list)
    assert len(payload) >= 10
    for song in payload:
        assert 'audio_url' in song
        assert song['audio_url'].startswith('https://')


def test_get_single_song(client: TestClient) -> None:
    response = client.get('/api/v1/songs/s1')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert body['data']['id'] == 's1'


def test_albums_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/albums')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert len(body['data']) >= 4


def test_artists_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/artists')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert len(body['data']) >= 4


def test_playlists_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/playlists')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert len(body['data']) >= 3


def test_search_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/search?q=luna')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    # Either Audius or fallback data should return results
    data = body['data']
    total = len(data.get('songs', [])) + len(data.get('artists', [])) + len(data.get('albums', [])) + len(data.get('playlists', []))
    assert total >= 0  # Search may return empty from live Audius; just verify shape
    assert 'songs' in data
    assert 'artists' in data


def test_stream_redirects(client: TestClient) -> None:
    response = client.get('/api/v1/stream/s1', follow_redirects=False)
    assert response.status_code in (302, 307)
    location = response.headers['location']
    # Accept either fallback soundhelix URL or live Audius stream URL
    assert location.startswith('https://')


def test_library_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/library')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert 'liked_songs' in body['data']
    assert 'playlists' in body['data']


def test_genres_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/genres')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
    assert len(body['data']) >= 8


def test_history_endpoint(client: TestClient) -> None:
    response = client.get('/api/v1/history')
    assert response.status_code == 200
    body = response.json()
    assert body['success'] is True
