import 'package:vmusic/features/home/domain/models/track_model.dart';

abstract class HomeRepository {
  Future<List<TrackModel>> getFeaturedTracks();
  Future<List<TrackModel>> getRecommendedTracks();
}
