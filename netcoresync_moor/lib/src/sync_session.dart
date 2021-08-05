import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_classes.dart';
import 'sync_handler.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  final DataAccess dataAccess;
  final SyncEvent? syncEvent;
  final Map<String, dynamic> customInfo;
  late SyncHandler _syncHandler;

  SyncSession({
    required this.dataAccess,
    required String url,
    this.syncEvent,
    this.customInfo = const {},
  }) {
    _syncHandler = SyncHandler(
      url: url,
      logger: dataAccess.logger,
    );
  }

  String get connectionId => _syncHandler.connectionId;

  Future<SyncResult> synchronize() async {
    return _perform((
      syncResult,
      handshakeResult,
    ) async {
      final handshakeResponsePayload =
          handshakeResult.payload as HandshakeResponsePayload;
      // TODO: continue main synchronize logic when ready
      print(handshakeResponsePayload.orderedClassNames);
    });
  }

  Future<SyncResult> request({required BasePayload payload}) {
    return _perform((
      syncResult,
      handshakeResult,
    ) async {
      // Only support a limited set of requests, mainly for integration tests
      // only
      late CompleterResult completerResult;
      if (EnumToString.fromString(PayloadActions.values, payload.action) ==
          PayloadActions.echoRequest) {
        completerResult = await _syncHandler.echo(
          payload: (payload as EchoRequestPayload),
        );
      } else if (EnumToString.fromString(
              PayloadActions.values, payload.action) ==
          PayloadActions.delayRequest) {
        completerResult = await _syncHandler.delay(
          payload: (payload as DelayRequestPayload),
        );
      } else if (EnumToString.fromString(
              PayloadActions.values, payload.action) ==
          PayloadActions.exceptionRequest) {
        completerResult = await _syncHandler.exception(
          payload: (payload as ExceptionRequestPayload),
        );
      } else if (EnumToString.fromString(
              PayloadActions.values, payload.action) ==
          PayloadActions.logRequest) {
        completerResult = await _syncHandler.log(
          payload: (payload as LogRequestPayload),
        );
      } else {
        throw Exception("Unexpected payload.action: ${payload.action}");
      }
      if (await _shouldTerminate(
        completerResult: completerResult,
        syncResult: syncResult,
      )) {
        return;
      }
    });
  }

  Future<SyncResult> _perform(
      Future<void> Function(
    SyncResult syncResult,
    CompleterResult handshakeResult,
  )
          action) async {
    final syncResult = SyncResult();

    _progress("Connecting...");
    _syncHandler.connect();

    _progress("Acquiring access...");
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
        await _syncHandler.handshake(payload: handshakeRequestPayload);
    // Do not call disconnect if should terminate here, or else this will be
    // stuck in syncHandler's await _channel.sink.close(). This is because this
    // "handshake" call is the first request that tries to send data to the
    // server (by calling _channel.sink.add() for the first time). So any calls
    // to sink.close() (the disconnect method) before establishing that the
    // sink.add() is connected to the server, will not work and will await
    // forever. I think this is the nature of web_socket_channel implementation,
    // where the connection is not really "opened" (or established) yet before
    // the first successful sink.add(). Read more here:
    // https://github.com/dart-lang/web_socket_channel/issues/70. But, if the
    // "handshake" call has already successfully send data, but returns an
    // error (for example, an errorMessage is returned from the server handler
    // OnHandshake), we should do disconnect here.
    if (await _shouldTerminate(
      completerResult: handshakeResult,
      syncResult: syncResult,
    )) {
      if (_syncHandler.connected) {
        await disconnect();
      }
      return syncResult;
    }

    try {
      await action(syncResult, handshakeResult);
    } finally {
      await disconnect();
    }

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
    required CompleterResult completerResult,
    required SyncResult syncResult,
  }) async {
    if (completerResult.errorMessage != null || completerResult.error != null) {
      syncResult.errorMessage = completerResult.errorMessage;
      syncResult.error = completerResult.error;
      return true;
    }
    return false;
  }

  Future<void> disconnect() async {
    _progress("Disconnecting...");
    if (_syncHandler.connected) {
      await _syncHandler.disconnect();
    }
  }
}
