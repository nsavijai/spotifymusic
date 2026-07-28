"""
Music routes
============
All music data comes from Audius via AudiusService.
If Audius is unavailable the routes fall back to local demo data so the
Flutter app always receives a valid response.

Flutter never calls Audius directly — it only talks to this backend.
"""

from __future__ import annotations

import logging

import httpx
from fastapi import APIRouter, Body, Query
from fastapi.responses import RedirectResponse

from app.features.music.services.audius_service import audius_service

logger = logging.getLogger(__name__)

router = APIRouter(tags=['music'])


def _ok(data: object, message: str = 'Success') -> dict[str, object]:
    return {'success': True, 'message': message, 'data': data}


def _err(message: str) -> dict[str, object]:
    return {'success': False, 'message': message, 'data': {}}


# ─── Fallback demo data (used only when Audius is unreachable) ────────────────

_FALLBACK_SONGS: list[dict] = [
    {
        'id': 's1', 'title': 'Midnight Drive', 'artist': 'Luna Vale',
        'artist_id': 'a1', 'album': 'Velvet Phase', 'album_id': 'al1',
        'image_url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        'duration_seconds': 204, 'year': 2024, 'is_favorite': False,
        'play_count': 4200000, 'lyrics': None, 'genre': 'Synth Pop',
    },
    {
        'id': 's2', 'title': 'Neon Skyline', 'artist': 'Aria North',
        'artist_id': 'a2', 'album': 'Future Bloom', 'album_id': 'al2',
        'image_url': 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        'duration_seconds': 241, 'year': 2024, 'is_favorite': False,
        'play_count': 2800000, 'lyrics': None, 'genre': 'Electronic',
    },
    {
        'id': 's3', 'title': 'Velvet Echo', 'artist': 'Milo Hart',
        'artist_id': 'a3', 'album': 'Afterglow', 'album_id': 'al3',
        'image_url': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        'duration_seconds': 178, 'year': 2023, 'is_favorite': False,
        'play_count': 5100000, 'lyrics': None, 'genre': 'Indie Soul',
    },
    {
        'id': 's4', 'title': 'Golden Hour', 'artist': 'Nora Lane',
        'artist_id': 'a4', 'album': 'Golden Hour', 'album_id': 'al4',
        'image_url': 'https://images.unsplash.com/photo-1498036882173-b41c28a8ba34?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        'duration_seconds': 198, 'year': 2024, 'is_favorite': False,
        'play_count': 3600000, 'lyrics': None, 'genre': 'Ambient Pop',
    },
    {
        'id': 's5', 'title': 'Electric Soul', 'artist': 'Luna Vale',
        'artist_id': 'a1', 'album': 'Velvet Phase', 'album_id': 'al1',
        'image_url': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        'duration_seconds': 223, 'year': 2024, 'is_favorite': False,
        'play_count': 1900000, 'lyrics': None, 'genre': 'Synth Pop',
    },
    {
        'id': 's6', 'title': 'Starfall', 'artist': 'Aria North',
        'artist_id': 'a2', 'album': 'Future Bloom', 'album_id': 'al2',
        'image_url': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        'duration_seconds': 267, 'year': 2024, 'is_favorite': False,
        'play_count': 2200000, 'lyrics': None, 'genre': 'Electronic',
    },
    {
        'id': 's7', 'title': 'Phantom Waves', 'artist': 'Milo Hart',
        'artist_id': 'a3', 'album': 'Afterglow', 'album_id': 'al3',
        'image_url': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        'duration_seconds': 195, 'year': 2023, 'is_favorite': False,
        'play_count': 3100000, 'lyrics': None, 'genre': 'Indie Soul',
    },
    {
        'id': 's8', 'title': 'Sunrise Protocol', 'artist': 'Nora Lane',
        'artist_id': 'a4', 'album': 'Golden Hour', 'album_id': 'al4',
        'image_url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        'duration_seconds': 312, 'year': 2024, 'is_favorite': False,
        'play_count': 1500000, 'lyrics': None, 'genre': 'Ambient Pop',
    },
    {
        'id': 's9', 'title': 'Cascade', 'artist': 'Luna Vale',
        'artist_id': 'a1', 'album': 'Velvet Phase', 'album_id': 'al1',
        'image_url': 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
        'duration_seconds': 189, 'year': 2024, 'is_favorite': False,
        'play_count': 2700000, 'lyrics': None, 'genre': 'Synth Pop',
    },
    {
        'id': 's10', 'title': 'Hollow Moon', 'artist': 'Aria North',
        'artist_id': 'a2', 'album': 'Future Bloom', 'album_id': 'al2',
        'image_url': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=600&q=80',
        'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
        'duration_seconds': 234, 'year': 2024, 'is_favorite': False,
        'play_count': 4800000, 'lyrics': None, 'genre': 'Electronic',
    },
]

_FALLBACK_ARTISTS: list[dict] = [
    {
        'id': 'a1', 'name': 'Luna Vale', 'genre': 'Synth Pop', 'is_verified': True,
        'image_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&q=80',
        'banner_url': 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80',
        'monthly_listeners': 18200000,
        'biography': 'Luna Vale is a Berlin-based synth-pop artist.',
        'popular_songs': [s for s in _FALLBACK_SONGS if s['artist_id'] == 'a1'],
        'albums': [],
    },
    {
        'id': 'a2', 'name': 'Aria North', 'genre': 'Electronic', 'is_verified': True,
        'image_url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&q=80',
        'banner_url': 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=1200&q=80',
        'monthly_listeners': 9400000,
        'biography': 'Aria North blends electronic production with soulful songwriting.',
        'popular_songs': [s for s in _FALLBACK_SONGS if s['artist_id'] == 'a2'],
        'albums': [],
    },
    {
        'id': 'a3', 'name': 'Milo Hart', 'genre': 'Indie Soul', 'is_verified': True,
        'image_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&q=80',
        'banner_url': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=1200&q=80',
        'monthly_listeners': 12100000,
        'biography': 'Milo Hart is a multi-instrumentalist from Nashville.',
        'popular_songs': [s for s in _FALLBACK_SONGS if s['artist_id'] == 'a3'],
        'albums': [],
    },
    {
        'id': 'a4', 'name': 'Nora Lane', 'genre': 'Ambient Pop', 'is_verified': False,
        'image_url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600&q=80',
        'banner_url': 'https://images.unsplash.com/photo-1498036882173-b41c28a8ba34?w=1200&q=80',
        'monthly_listeners': 7600000,
        'biography': 'Nora Lane creates immersive ambient pop landscapes.',
        'popular_songs': [s for s in _FALLBACK_SONGS if s['artist_id'] == 'a4'],
        'albums': [],
    },
]

_FALLBACK_PLAYLISTS: list[dict] = [
    {
        'id': 'p1', 'title': 'Late Night Vibes', 'owner': 'You', 'followers': 12300,
        'is_public': True, 'is_owned': True,
        'description': 'A reflective mix for urban evenings.',
        'image_url': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
        'songs': _FALLBACK_SONGS[:5],
    },
    {
        'id': 'p2', 'title': 'Sunset Runs', 'owner': 'VMusic', 'followers': 84000,
        'is_public': True, 'is_owned': False,
        'description': 'Energetic beats for the golden hour.',
        'image_url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
        'songs': _FALLBACK_SONGS[3:7],
    },
    {
        'id': 'p3', 'title': 'Focus Flow', 'owner': 'VMusic', 'followers': 230000,
        'is_public': True, 'is_owned': False,
        'description': 'Deep concentration music.',
        'image_url': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=600&q=80',
        'songs': _FALLBACK_SONGS[5:],
    },
]

# In-memory liked songs state (per-process, resets on restart)
_liked_song_ids: set[str] = set()


# ─── Routes ───────────────────────────────────────────────────────────────────

@router.get('/songs')
async def list_songs(limit: int = Query(20, ge=1, le=100)) -> list[dict]:
    """Returns trending tracks from Audius, falls back to demo data."""
    try:
        songs = await audius_service.get_trending_tracks(limit=limit)
        if songs:
            return songs
    except Exception as exc:
        logger.warning('Audius trending unavailable: %s', exc)
    return _FALLBACK_SONGS


@router.get('/songs/{song_id}')
async def get_song(song_id: str) -> dict[str, object]:
    try:
        song = await audius_service.get_track(song_id)
        return _ok(song)
    except Exception as exc:
        logger.warning('Audius track %s unavailable: %s', song_id, exc)
        fallback = next((s for s in _FALLBACK_SONGS if s['id'] == song_id), _FALLBACK_SONGS[0])
        return _ok(fallback)


@router.get('/artists')
async def list_artists(limit: int = Query(10, ge=1, le=50)) -> dict[str, object]:
    try:
        artists = await audius_service.get_popular_artists(limit=limit)
        if artists:
            return _ok(artists)
    except Exception as exc:
        logger.warning('Audius artists unavailable: %s', exc)
    return _ok(_FALLBACK_ARTISTS)


@router.get('/artists/{artist_id}')
async def get_artist(artist_id: str) -> dict[str, object]:
    try:
        artist = await audius_service.get_artist(artist_id)
        return _ok(artist)
    except Exception as exc:
        logger.warning('Audius artist %s unavailable: %s', artist_id, exc)
        fallback = next((a for a in _FALLBACK_ARTISTS if a['id'] == artist_id), _FALLBACK_ARTISTS[0])
        return _ok(fallback)


@router.get('/albums')
async def list_albums() -> dict[str, object]:
    # Audius doesn't have a standalone albums list endpoint;
    # we return albums derived from fallback data.
    albums = _build_fallback_albums()
    return _ok(albums)


@router.get('/albums/{album_id}')
async def get_album(album_id: str) -> dict[str, object]:
    albums = _build_fallback_albums()
    album = next((a for a in albums if a['id'] == album_id), albums[0])
    return _ok(album)


@router.get('/playlists')
async def list_playlists(limit: int = Query(10, ge=1, le=50)) -> dict[str, object]:
    try:
        playlists = await audius_service.get_trending_playlists(limit=limit)
        if playlists:
            return _ok(playlists)
    except Exception as exc:
        logger.warning('Audius playlists unavailable: %s', exc)
    return _ok(_FALLBACK_PLAYLISTS)


@router.get('/playlists/{playlist_id}')
async def get_playlist(playlist_id: str) -> dict[str, object]:
    try:
        playlist = await audius_service.get_playlist(playlist_id)
        return _ok(playlist)
    except Exception as exc:
        logger.warning('Audius playlist %s unavailable: %s', playlist_id, exc)
        fallback = next(
            (p for p in _FALLBACK_PLAYLISTS if p['id'] == playlist_id),
            _FALLBACK_PLAYLISTS[0],
        )
        return _ok(fallback)


@router.post('/playlists')
async def create_playlist(payload: dict = Body(...)) -> dict[str, object]:
    new_pl = {
        'id': f"user_p_{len(_FALLBACK_PLAYLISTS) + 1}",
        'title': payload.get('title', 'New Playlist'),
        'description': payload.get('description', ''),
        'image_url': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
        'owner': 'You',
        'followers': 0,
        'is_public': payload.get('is_public', True),
        'is_owned': True,
        'songs': [],
    }
    _FALLBACK_PLAYLISTS.append(new_pl)
    return _ok(new_pl, 'Playlist created')


@router.put('/playlists/{playlist_id}')
async def update_playlist(playlist_id: str, payload: dict = Body(...)) -> dict[str, object]:
    for pl in _FALLBACK_PLAYLISTS:
        if pl['id'] == playlist_id:
            pl.update({k: v for k, v in payload.items() if k in ('title', 'description', 'is_public')})
            return _ok(pl, 'Playlist updated')
    return _err('Playlist not found')


@router.delete('/playlists/{playlist_id}')
async def delete_playlist(playlist_id: str) -> dict[str, object]:
    return _ok({'id': playlist_id}, 'Playlist deleted')


@router.get('/genres')
async def list_genres() -> dict[str, object]:
    return _ok(audius_service.get_genres())


@router.get('/search')
async def search(q: str = Query('')) -> dict[str, object]:
    if not q.strip():
        return _ok({'songs': [], 'artists': [], 'albums': [], 'playlists': []})
    try:
        results = await audius_service.search(q)
        # If Audius returned results, use them
        if results.get('songs') or results.get('artists'):
            return _ok(results)
    except Exception as exc:
        logger.warning('Audius search unavailable: %s', exc)
    # Fallback to local data
    q_lower = q.lower()
    return _ok({
        'songs': [s for s in _FALLBACK_SONGS
                  if q_lower in s['title'].lower() or q_lower in s['artist'].lower()],
        'artists': [a for a in _FALLBACK_ARTISTS if q_lower in a['name'].lower()],
        'albums': [],
        'playlists': [p for p in _FALLBACK_PLAYLISTS if q_lower in p['title'].lower()],
    })


@router.get('/library')
async def get_library() -> dict[str, object]:
    liked = [s for s in _FALLBACK_SONGS if s['id'] in _liked_song_ids]
    return _ok({
        'liked_songs': liked,
        'playlists': [p for p in _FALLBACK_PLAYLISTS if p.get('is_owned')],
        'albums': _build_fallback_albums(),
        'recently_played': _FALLBACK_SONGS[:5],
    })


@router.post('/library/like')
async def like_song(payload: dict = Body(...)) -> dict[str, object]:
    song_id = payload.get('song_id', '')
    _liked_song_ids.add(song_id)
    return _ok({'song_id': song_id, 'is_favorite': True})


@router.delete('/library/like/{song_id}')
async def unlike_song(song_id: str) -> dict[str, object]:
    _liked_song_ids.discard(song_id)
    return _ok({'song_id': song_id, 'is_favorite': False})


@router.get('/history')
async def get_history() -> dict[str, object]:
    return _ok(_FALLBACK_SONGS[:5])


@router.post('/history')
async def record_history(payload: dict = Body(...)) -> dict[str, object]:
    return _ok(payload, 'History recorded')


@router.get('/stream/{song_id}')
async def stream_song(song_id: str) -> RedirectResponse:
    """
    Resolve the audio stream URL for a song.
    First tries Audius; falls back to demo MP3 if unavailable.
    Flutter always calls this endpoint — never Audius directly.
    """
    try:
        stream_url = await audius_service.get_track_stream_url(song_id)
        return RedirectResponse(url=stream_url, status_code=302)
    except Exception as exc:
        logger.warning('Audius stream %s unavailable: %s', song_id, exc)

    # Fallback: find in local data
    fallback = next((s for s in _FALLBACK_SONGS if s['id'] == song_id), _FALLBACK_SONGS[0])
    return RedirectResponse(url=fallback['audio_url'], status_code=302)


@router.get('/health')
async def health() -> dict[str, object]:
    return _ok({'status': 'ok'})


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _build_fallback_albums() -> list[dict]:
    album_ids = {s['album_id'] for s in _FALLBACK_SONGS if s['album_id']}
    albums = []
    for aid in album_ids:
        songs = [s for s in _FALLBACK_SONGS if s['album_id'] == aid]
        if not songs:
            continue
        first = songs[0]
        albums.append({
            'id': aid,
            'title': first['album'],
            'artist': first['artist'],
            'artist_id': first['artist_id'],
            'image_url': first['image_url'],
            'year': first['year'],
            'genre': first.get('genre', ''),
            'description': '',
            'songs': songs,
        })
    return albums
