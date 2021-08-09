class NetCoreSyncException implements Exception {
  final String message;
  const NetCoreSyncException([this.message = ""]);
  @override
  String toString() => "NetCoreSyncException: $message";
}

class NetCoreSyncNotInitializedException extends NetCoreSyncException {
  const NetCoreSyncNotInitializedException()
      : super("Client is not initialized yet");
}

class NetCoreSyncSyncIdInfoNotSetException extends NetCoreSyncException {
  const NetCoreSyncSyncIdInfoNotSetException()
      : super("SyncIdInfo is not set yet");
}

class NetCoreSyncMustNotInsideTransactionException
    extends NetCoreSyncException {
  const NetCoreSyncMustNotInsideTransactionException()
      : super("This method call must not be wrapped inside Transaction");
}

class NetCoreSyncTypeNotRegisteredException extends NetCoreSyncException {
  const NetCoreSyncTypeNotRegisteredException(Type type)
      : super("The type: $type is not registered correctly in NetCoreSync. "
            "Please check your @NetCoreSyncTable annotation on its Table "
            "class.");
}

class NetCoreSyncSocketException extends NetCoreSyncException {
  const NetCoreSyncSocketException(String message) : super(message);
}

class NetCoreSyncServerException implements Exception {
  final String message;
  const NetCoreSyncServerException([this.message = ""]);
  @override
  String toString() => "NetCoreSyncServerException: $message";
}

class NetCoreSyncServerSyncIdInfoOverlappedException
    extends NetCoreSyncServerException {
  final List<String> overlappedSyncIds;
  NetCoreSyncServerSyncIdInfoOverlappedException(this.overlappedSyncIds)
      : super(
            "The following syncIds are overlapped and currently synchronizing: "
            "${overlappedSyncIds.join(", ")}");
}
