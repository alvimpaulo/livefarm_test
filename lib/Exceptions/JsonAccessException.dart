class JsonAccessException implements Exception {
  String message;
  String key;
  JsonAccessException({required this.message, required this.key});
}
