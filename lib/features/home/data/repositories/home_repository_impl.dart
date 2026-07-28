import 'package:vmusic/features/home/data/datasources/home_remote_data_source.dart';
import 'package:vmusic/features/home/domain/models/track_model.dart';
import 'package:vmusic/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<List<TrackModel>> getFeaturedTracks() {
    return _remoteDataSource.getFeaturedTracks();
  }

  @override
  Future<List<TrackModel>> getRecommendedTracks() {
    return _remoteDataSource.getRecommendedTracks();
  }
}
