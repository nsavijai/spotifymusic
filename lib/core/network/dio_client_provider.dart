import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

/// Riverpod provider exposing the singleton [DioClient]
/// so other providers can obtain the configured Dio instance.
final dioClientProvider = Provider<DioClient>((ref) => DioClient.instance);
