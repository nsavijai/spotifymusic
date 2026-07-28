import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../repositories/auth_repository.dart';

/// Provides an instance of [AuthRepository] using the shared [dioClientProvider].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return AuthRepository(dio);
});
