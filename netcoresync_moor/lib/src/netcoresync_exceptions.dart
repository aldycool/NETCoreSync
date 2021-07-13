class NetCoreSyncException implements Exception {
  final String message;
  const NetCoreSyncException([this.message = ""]);
  String toString() => "NetCoreSyncException: $message";
}

class NetCoreSyncMustInsideTransactionException extends NetCoreSyncException {
  NetCoreSyncMustInsideTransactionException()
      : super("Sync methods must be wrapped inside Transaction");
}
