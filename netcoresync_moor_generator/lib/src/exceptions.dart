class NetCoreSyncMoorGeneratorException implements Exception {
  final String message;
  const NetCoreSyncMoorGeneratorException([this.message = ""]);
  @override
  String toString() => "NetCoreSyncMoorGeneratorException: $message";
}
