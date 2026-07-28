import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../repositories/music_repository.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return MusicRepository(dio);
});
