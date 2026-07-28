// Home-specific providers delegate to the shared music providers.
// This file is kept for backward compatibility with any widget that imports it.
export '../../../music/data/providers/music_providers.dart'
    show
        songsProvider,
        albumsProvider,
        artistsProvider,
        playlistsProvider,
        genresProvider,
        searchProvider,
        SearchState,
        SearchNotifier;
