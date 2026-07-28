import '../../domain/models/track_model.dart';

class HomeRepository {
  const HomeRepository();

  Future<List<TrackModel>> fetchFeaturedTracks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [];
  }
}
