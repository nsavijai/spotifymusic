"""
AudiusService
=============
Single integration layer between VMusic backend and the Audius public API.
All Audius responses are mapped into VMusic's internal dict format before
being returned to routes. Flutter never knows Audius exists.

Audius public API docs: https://audiusproject.github.io/api-docs/
"""

from __future__ import annotations

import time
from typing import Any

import httpx

from app.core.config.settings import settings

# ─── Simple in-process TTL cache ─────────────────────────────────────────────
_cache: dict[str, tuple[Any, float]] = {}


def _cached(key: str, ttl: int = settings.audius_cache_ttl_seconds) -> Any | None:
    entry = _cache.get(key)
    if entry and time.monotonic() - entry[1] < ttl:
        return entry[0]
    return None


def _store(key: str, value: Any) -> None:
    _cache[key] = (value, time.monotonic())


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _base_headers() -> dict[str, str]:
    return {'Accept': 'application/json'}


def _params(**kwargs: Any) -> dict[str, Any]:
    p: dict[str, Any] = {'app_name': settings.audius_app_name}
    p.update({k: v for k, v in kwargs.items() if v is not None})
    return p


def _artwork(artwork: dict | None, size: str = '480x480') -> str:
    if not artwork:
        return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80'
    url: str = artwork.get(size) or artwork.get('150x150') or ''
    return url if url else 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80'


def _cover_photo(photo: dict | None, size: str = '2000x') -> str:
    if not photo:
        return 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80'
    url: str = photo.get(size) or photo.get('640x') or ''
    return url if url else 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80'


def _stream_url(track_id: str) -> str:
    """Return the VMusic backend stream URL — never expose Audius directly."""
    return f'/api/v1/stream/{track_id}'


def _map_track(t: dict) -> dict:
    """Map a raw Audius track object to VMusic's SongModel-compatible dict."""
    user = t.get('user') or {}
    artwork = t.get('artwork') or {}
    duration = t.get('duration') or 0
    return {
        'id': t.get('id', ''),
        'title': t.get('title', 'Unknown'),
        'artist': user.get('name', 'Unknown Artist'),
        'artist_id': user.get('id', ''),
        'album': t.get('album', {}).get('playlist_name', '') if t.get('album') else '',
        'album_id': t.get('album', {}).get('id', '') if t.get('album') else '',
        'image_url': _artwork(artwork),
        'audio_url': f'{settings.audius_api_base}/tracks/{t["id"]}/stream?app_name={settings.audius_app_name}',
        'duration_seconds': int(duration),
        'year': int(t.get('release_date', '2024')[:4]) if t.get('release_date') else 2024,
        'is_favorite': False,
        'play_count': t.get('play_count', 0),
        'lyrics': None,
        'genre': t.get('genre', ''),
    }


def _map_artist(u: dict, popular_songs: list[dict] | None = None) -> dict:
    """Map a raw Audius user object to VMusic's ArtistModel-compatible dict."""
    cover = u.get('cover_photo') or {}
    artwork = u.get('profile_picture') or {}
    return {
        'id': u.get('id', ''),
        'name': u.get('name', 'Unknown Artist'),
        'genre': u.get('genre', ''),
        'is_verified': u.get('is_verified', False),
        'image_url': _artwork(artwork),
        'banner_url': _cover_photo(cover),
        'monthly_listeners': u.get('follower_count', 0),
        'biography': u.get('bio', ''),
        'popular_songs': popular_songs or [],
        'albums': [],
    }


def _map_playlist(p: dict, tracks: list[dict] | None = None) -> dict:
    """Map a raw Audius playlist/album object to VMusic's PlaylistModel-compatible dict."""
    artwork = p.get('artwork') or {}
    user = p.get('user') or {}
    return {
        'id': p.get('id', ''),
        'title': p.get('playlist_name', 'Untitled'),
        'description': p.get('description', ''),
        'image_url': _artwork(artwork),
        'owner': user.get('name', 'VMusic'),
        'followers': p.get('repost_count', 0),
        'is_public': not p.get('is_private', False),
        'is_owned': False,
        'songs': tracks or [],
    }


# ─── AudiusService ────────────────────────────────────────────────────────────

class AudiusService:
    """
    All methods are async and return VMusic-internal dicts.
    Raises httpx.HTTPError on network failures (caller handles gracefully).
    """

    def __init__(self) -> None:
        self._client = httpx.AsyncClient(
            base_url=settings.audius_api_base,
            headers=_base_headers(),
            timeout=10.0,
            follow_redirects=True,
        )

    async def aclose(self) -> None:
        await self._client.aclose()

    # ── Trending ──────────────────────────────────────────────────────────────

    async def get_trending_tracks(self, limit: int = 20) -> list[dict]:
        key = f'trending:{limit}'
        if cached := _cached(key):
            return cached
        resp = await self._client.get(
            '/tracks/trending',
            params=_params(limit=limit),
        )
        resp.raise_for_status()
        tracks = [_map_track(t) for t in resp.json().get('data', [])]
        _store(key, tracks)
        return tracks

    # ── Search ────────────────────────────────────────────────────────────────

    async def search(self, query: str, limit: int = 20) -> dict:
        key = f'search:{query}:{limit}'
        if cached := _cached(key, ttl=60):
            return cached

        tracks_resp, users_resp = await _parallel_search(self._client, query, limit)

        songs = [_map_track(t) for t in tracks_resp.get('data', [])]
        artists = [_map_artist(u) for u in users_resp.get('data', [])]

        result = {
            'songs': songs,
            'artists': artists,
            'albums': [],
            'playlists': [],
        }
        _store(key, result)
        return result

    # ── Tracks ────────────────────────────────────────────────────────────────

    async def get_track(self, track_id: str) -> dict:
        key = f'track:{track_id}'
        if cached := _cached(key):
            return cached
        resp = await self._client.get(
            f'/tracks/{track_id}',
            params=_params(),
        )
        resp.raise_for_status()
        track = _map_track(resp.json()['data'])
        _store(key, track)
        return track

    async def get_track_stream_url(self, track_id: str) -> str:
        """Returns the direct Audius stream URL for a given track ID."""
        return f'{settings.audius_api_base}/tracks/{track_id}/stream?app_name={settings.audius_app_name}'

    # ── Artists ───────────────────────────────────────────────────────────────

    async def get_popular_artists(self, limit: int = 10) -> list[dict]:
        key = f'popular_artists:{limit}'
        if cached := _cached(key):
            return cached
        # Audius doesn't have a "popular artists" endpoint directly;
        # we derive them from trending track artists.
        trending = await self.get_trending_tracks(limit=50)
        seen: set[str] = set()
        artists: list[dict] = []
        for t in trending:
            aid = t['artist_id']
            if aid and aid not in seen:
                seen.add(aid)
                artists.append({
                    'id': aid,
                    'name': t['artist'],
                    'genre': t.get('genre', ''),
                    'is_verified': False,
                    'image_url': t['image_url'],
                    'banner_url': t['image_url'],
                    'monthly_listeners': 0,
                    'biography': '',
                    'popular_songs': [],
                    'albums': [],
                })
            if len(artists) >= limit:
                break
        _store(key, artists)
        return artists

    async def get_artist(self, user_id: str) -> dict:
        key = f'artist:{user_id}'
        if cached := _cached(key):
            return cached
        resp = await self._client.get(f'/users/{user_id}', params=_params())
        resp.raise_for_status()
        user_data = resp.json()['data']

        # Fetch top tracks for this artist
        tracks_resp = await self._client.get(
            f'/users/{user_id}/tracks',
            params=_params(limit=10),
        )
        songs: list[dict] = []
        if tracks_resp.is_success:
            songs = [_map_track(t) for t in tracks_resp.json().get('data', [])]

        artist = _map_artist(user_data, popular_songs=songs)
        _store(key, artist)
        return artist

    # ── Playlists ─────────────────────────────────────────────────────────────

    async def get_trending_playlists(self, limit: int = 10) -> list[dict]:
        key = f'trending_playlists:{limit}'
        if cached := _cached(key):
            return cached
        resp = await self._client.get(
            '/playlists/trending',
            params=_params(limit=limit),
        )
        resp.raise_for_status()
        playlists = [_map_playlist(p) for p in resp.json().get('data', [])]
        _store(key, playlists)
        return playlists

    async def get_playlist(self, playlist_id: str) -> dict:
        key = f'playlist:{playlist_id}'
        if cached := _cached(key):
            return cached
        resp = await self._client.get(
            f'/playlists/{playlist_id}',
            params=_params(),
        )
        resp.raise_for_status()
        pl_data = resp.json()['data'][0] if isinstance(resp.json()['data'], list) else resp.json()['data']

        # Fetch tracks
        tracks_resp = await self._client.get(
            f'/playlists/{playlist_id}/tracks',
            params=_params(),
        )
        songs: list[dict] = []
        if tracks_resp.is_success:
            songs = [_map_track(t) for t in tracks_resp.json().get('data', [])]

        playlist = _map_playlist(pl_data, tracks=songs)
        _store(key, playlist)
        return playlist

    # ── Genres ────────────────────────────────────────────────────────────────

    def get_genres(self) -> list[dict]:
        return [
            {'id': 'g1', 'name': 'Electronic', 'color': 0x9B59B6,
             'image_url': 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400&q=80'},
            {'id': 'g2', 'name': 'Hip-Hop/Rap', 'color': 0x1ED760,
             'image_url': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400&q=80'},
            {'id': 'g3', 'name': 'Lo-Fi', 'color': 0xE67E22,
             'image_url': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&q=80'},
            {'id': 'g4', 'name': 'R&B/Soul', 'color': 0xE74C3C,
             'image_url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=80'},
            {'id': 'g5', 'name': 'House', 'color': 0x3498DB,
             'image_url': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80'},
            {'id': 'g6', 'name': 'Alternative', 'color': 0x1ABC9C,
             'image_url': 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=400&q=80'},
            {'id': 'g7', 'name': 'Pop', 'color': 0xF39C12,
             'image_url': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80'},
            {'id': 'g8', 'name': 'Ambient', 'color': 0x8E44AD,
             'image_url': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80'},
        ]


async def _parallel_search(
    client: httpx.AsyncClient, query: str, limit: int
) -> tuple[dict, dict]:
    """Run track and user searches concurrently."""
    import asyncio
    tracks_task = asyncio.create_task(
        client.get('/tracks/search', params=_params(query=query, limit=limit))
    )
    users_task = asyncio.create_task(
        client.get('/users/search', params=_params(query=query, limit=limit))
    )
    tracks_resp, users_resp = await asyncio.gather(
        tracks_task, users_task, return_exceptions=True
    )
    tracks_data: dict = {}
    users_data: dict = {}
    if isinstance(tracks_resp, httpx.Response) and tracks_resp.is_success:
        tracks_data = tracks_resp.json()
    if isinstance(users_resp, httpx.Response) and users_resp.is_success:
        users_data = users_resp.json()
    return tracks_data, users_data


# Singleton instance
audius_service = AudiusService()
