import 'netcoresync_classes.dart';
import 'sync_socket.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  final DataAccess dataAccess;
  final SyncEvent? syncEvent;
  final Map<String, dynamic> customInfo;
  late SyncSocket _syncSocket;
  String? connectionId;

  SyncSession({
    required this.dataAccess,
    required String url,
    this.syncEvent,
    this.customInfo = const {},
  }) {
    _syncSocket = SyncSocket(
      url: url,
      logger: dataAccess.logger,
    );
  }

  Future<SyncResult> synchronize() async {
    final syncResult = SyncResult();

    _progress("Connecting...");
    final connectResult = await _syncSocket.connect();
    if (connectResult.errorMessage != null || connectResult.error != null) {
      syncResult.errorMessage = connectResult.errorMessage;
      syncResult.error = connectResult.error;
      await _syncSocket.close();
      return syncResult;
    }
    connectionId = connectResult.connectionId;

    late ResponseResult responseResult;

    _progress("Acquiring access...");
    responseResult = await _syncSocket.request(
      payload: HandshakeRequestPayload(
        schemaVersion: dataAccess.database.schemaVersion,
        syncIdInfo: dataAccess.syncIdInfo!,
      ),
    );
    if (await _shouldTerminate(
      responseResult: responseResult,
      syncResult: syncResult,
    )) {
      return syncResult;
    }

    // TODO: continue main synchronize logic when ready

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

    return syncResult;
  }

  void _progress(
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

  Future<bool> _shouldTerminate({
    required ResponseResult responseResult,
    required SyncResult syncResult,
  }) async {
    if (responseResult.errorMessage != null || responseResult.error != null) {
      syncResult.errorMessage = responseResult.errorMessage;
      syncResult.error = responseResult.error;
      await _syncSocket.close();
      return true;
    }
    return false;
  }
}
