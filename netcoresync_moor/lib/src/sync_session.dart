import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:uuid/uuid.dart';
import 'sync_handler.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  final SyncHandler syncHandler;
  final DataAccess dataAccess;
  final SyncEvent? syncEvent;
  final Map<String, dynamic> customInfo;

  SyncSession({
    required this.syncHandler,
    required this.dataAccess,
    this.syncEvent,
    this.customInfo = const {},
  });

  Future<SyncResult> synchronize() async {
    final syncResult = SyncResult();

    progress("Connecting...");
    syncHandler.connect();

    progress("Validating connection...");
    final echoRequestPayload = EchoRequestPayload(
      message: Uuid().v4(),
    );
    final echoResult = await syncHandler.echo(
      payload: echoRequestPayload,
    );
    if (echoResult.errorMessage != null) {
      syncResult.errorMessage = echoResult.errorMessage;
      return syncResult;
    }
    final echoResponsePayload = echoResult.payload as EchoResponsePayload;
    if (echoResponsePayload.message != echoRequestPayload.message) {
      syncResult.errorMessage =
          "Response echoMessage: ${echoResponsePayload.message} is different "
          "than Request echoMessage: ${echoRequestPayload.message}";
      return syncResult;
    }

    progress("Acquiring access...");
    final handshakeRequestPayload = HandshakeRequestPayload(
      schemaVersion: dataAccess.database.schemaVersion,
      syncIdInfo: dataAccess.syncIdInfo!,
    );
    // TODO: On Server's handshake handler (after user's syncEvent), pay
    // attention to perform .NET thread locking on:
    // 1. The same device tries to sync again (although this is highly
    // unlikely because the mechanism has been tested for normal / forced
    // closing on both sides, so both sockets should be closed completely)
    // 2. The carried syncId + its linkedSyncIds should reserve the sync
    // process, and no other device with overlapped syncId + linkedSyncIds
    // should be able to do sync (queue + notification by progress)
    // 3. In this case, there should be an opportunity to cancel the operation.
    // - For tackling issue #1, somehow mark the current active connection in
    // the server, probably using the currently logged-in local knowledgeId.
    // - For tackling issue #2, there should be an active lockObject in the .NET
    // SyncMiddleware instance, most probably the "syncService"
    // itself because it is registered as a Singleton in DI. With this
    // lockObject, use Dictionary to calculate the overlapped syncIds +
    // linkedSyncIds. To know more the nature of the Middleware scope of life,
    // read this: https://stevetalkscode.co.uk/middleware-styles
    final handshakeResult =
        await syncHandler.handshake(payload: handshakeRequestPayload);
    if (handshakeResult.errorMessage != null) {
      syncResult.errorMessage = handshakeResult.errorMessage;
      return syncResult;
    }
    final handshakeResponsePayload =
        handshakeResult.payload as HandshakeResponsePayload;
    print(handshakeResponsePayload.orderedClassNames);

    progress("Disconnecting...");
    await syncHandler.disconnect();

    return syncResult;
  }

  void progress(
    String message, {
    double current = 0,
    double min = 0,
    double max = 0,
  }) {
    syncEvent?.progressEvent?.call(
      message,
      current,
      min,
      max,
    );
  }
}
