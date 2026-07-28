import 'package:vmusic/features/home/domain/models/track_model.dart';
import 'package:vmusic/features/home/domain/repositories/home_repository.dart';

class GetHomeContent {
  GetHomeContent(this._repository);

  final HomeRepository _repository;

  Future<List<TrackModel>> featuredTracks() {
    return _repository.getFeaturedTracks();
  }

  Future<List<TrackModel>> recommendedTracks() {
    return _repository.getRecommendedTracks();
  }
}
