class ApiException implements Exception {
  const ApiException({required this.message});
  final String message;
  @override
  String toString() => 'ApiException: $message';
}
