class NetCoreSyncException implements Exception {
  final String message;
  const NetCoreSyncException([this.message = ""]);
  @override
  String toString() => "NetCoreSyncException: $message";
}

class NetCoreSyncSocketException extends NetCoreSyncException {
  NetCoreSyncSocketException(String message) : super(message);
}

class NetCoreSyncNotInitializedException extends NetCoreSyncException {
  NetCoreSyncNotInitializedException() : super("Client is not initialized yet");
}

class NetCoreSyncSyncIdInfoNotSetException extends NetCoreSyncException {
  NetCoreSyncSyncIdInfoNotSetException() : super("SyncIdInfo is not set yet");
}

class NetCoreSyncMustNotInsideTransactionException
    extends NetCoreSyncException {
  NetCoreSyncMustNotInsideTransactionException()
      : super("This method call must not be wrapped inside Transaction");
}

class NetCoreSyncTypeNotRegisteredException extends NetCoreSyncException {
  NetCoreSyncTypeNotRegisteredException(Type type)
      : super("The type: $type is not registered correctly in NetCoreSync. "
            "Please check your @NetCoreSyncTable annotation on its Table "
            "class.");
}
