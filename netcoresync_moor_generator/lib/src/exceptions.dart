class NetCoreSyncMoorGeneratorException implements Exception {
  final String message;
  const NetCoreSyncMoorGeneratorException([this.message = ""]);
  String toString() => "NetCoreSyncMoorGeneratorException: $message";
}
