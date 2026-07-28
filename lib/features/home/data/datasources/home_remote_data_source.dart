import 'package:vmusic/features/home/domain/models/track_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<TrackModel>> getFeaturedTracks();
  Future<List<TrackModel>> getRecommendedTracks();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<TrackModel>> getFeaturedTracks() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      TrackModel(
        title: 'Midnight Echoes',
        subtitle: 'Astra Vale',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80',
        duration: '3:42',
        isFavorite: true,
      ),
      TrackModel(
        title: 'Velvet Skyline',
        subtitle: 'Luna Reed',
        imageUrl:
            'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80',
        duration: '4:12',
      ),
      TrackModel(
        title: 'Neon Summer',
        subtitle: 'Milo & June',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80',
        duration: '2:58',
      ),
    ];
  }

  @override
  Future<List<TrackModel>> getRecommendedTracks() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const [
      TrackModel(
        title: 'Northbound',
        subtitle: 'Sage Atlas',
        imageUrl:
            'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=900&q=80',
        duration: '3:18',
        isFavorite: true,
      ),
      TrackModel(
        title: 'Afterglow',
        subtitle: 'Nia Sol',
        imageUrl:
            'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=900&q=80',
        duration: '4:01',
      ),
      TrackModel(
        title: 'Golden Hour',
        subtitle: 'Dario Lane',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80',
        duration: '2:44',
      ),
    ];
  }
}
