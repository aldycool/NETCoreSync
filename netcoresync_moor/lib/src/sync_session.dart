import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:uuid/uuid.dart';
import 'sync_handler.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  late SyncHandler syncHandler;
  final DataAccess dataAccess;
  final SyncEvent? syncEvent;
  final Map<String, dynamic> customInfo;

  SyncSession({
    required this.dataAccess,
    required String url,
    this.syncEvent,
    this.customInfo = const {},
  }) {
    syncHandler = SyncHandler(
      url: url,
    );
  }

  Future<SyncResult> synchronize() async {
    final syncResult = SyncResult();

    Future<void> localDisconnect() async {
      progress("Disconnecting...");
      if (syncHandler.connected) {
        await syncHandler.disconnect();
      }
    }

    Future<bool> localShouldTerminate({
      required CompleterResult completerResult,
      bool shouldDisconnect = true,
    }) async {
      if (completerResult.errorMessage != null ||
          completerResult.error != null) {
        syncResult.errorMessage = completerResult.errorMessage;
        syncResult.error = completerResult.error;
        if (shouldDisconnect) {
          await localDisconnect();
        }
        return true;
      }
      return false;
    }

    progress("Connecting...");
    syncHandler.connect();

    progress("Validating connection...");
    final echoRequestPayload = EchoRequestPayload(
      message: Uuid().v4(),
    );
    final echoResult = await syncHandler.echo(
      payload: echoRequestPayload,
    );
    // Do not call disconnect if should terminate here, or else this will be
    // stuck in syncHandler's await _channel.sink.close(). This is because this
    // "Echo" call is the first request to validate connection, therefore, by
    // the nature of web_socket_channel implementation, the connection is not
    // actually "opened" (or established) yet. Read more here:
    // https://github.com/dart-lang/web_socket_channel/issues/70
    if (await localShouldTerminate(
      completerResult: echoResult,
      shouldDisconnect: false,
    )) {
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
    if (await localShouldTerminate(
      completerResult: handshakeResult,
    )) {
      return syncResult;
    }
    final handshakeResponsePayload =
        handshakeResult.payload as HandshakeResponsePayload;
    print(handshakeResponsePayload.orderedClassNames);

    progress("Test send log...");
    final logRequestPayload = LogRequestPayload(
      message: "This is a [LOREM-IPSUM] test log, you should catch it!",
    );
    final logResult = await syncHandler.log(payload: logRequestPayload);
    if (await localShouldTerminate(
      completerResult: logResult,
    )) {
      return syncResult;
    }

    await localDisconnect();

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
