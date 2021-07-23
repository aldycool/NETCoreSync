class NetCoreSyncException implements Exception {
  final String message;
  const NetCoreSyncException([this.message = ""]);
  @override
  String toString() => "NetCoreSyncException: $message";
}

class NetCoreSyncNotInitializedException extends NetCoreSyncException {
  NetCoreSyncNotInitializedException() : super("Client is not initialized yet");
}

class NetCoreSyncMustInsideTransactionException extends NetCoreSyncException {
  NetCoreSyncMustInsideTransactionException()
      : super("Sync methods must be wrapped inside Transaction");
}

class NetCoreSyncTypeNotRegisteredException extends NetCoreSyncException {
  NetCoreSyncTypeNotRegisteredException(Type type)
      : super(
            "The type: $type is not registered correctly in NetCoreSync. Please check your @NetCoreSyncTable annotation on its Table class.");
}
