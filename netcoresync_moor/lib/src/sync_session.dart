import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:uuid/uuid.dart';
import 'sync_handler.dart';
import 'data_access.dart';
import 'sync_messages.dart';

class SyncSession {
  final SyncHandler syncHandler;
  final DataAccess dataAccess;
  final Map<String, dynamic> customInfo;

  SyncSession({
    required this.syncHandler,
    required this.dataAccess,
    this.customInfo = const {},
  });

  Future<void> synchronize() async {
    syncHandler.connect();

    final echoRequestPayload = EchoRequestPayload(
      message: Uuid().v4(),
    );
    final echoResponsePayload = await syncHandler.echo(
      payload: echoRequestPayload,
    );
    if (echoResponsePayload.message != echoRequestPayload.message) {
      throw NetCoreSyncException(
          "Response echoMessage: ${echoResponsePayload.message} is "
          "different than Request echoMessage: ${echoRequestPayload.message}");
    }

    final handshakeRequestPayload = HandshakeRequestPayload(
      schemaVersion: dataAccess.database.schemaVersion,
      syncIdInfo: dataAccess.syncIdInfo!,
    );
    final handshakeResponsePayload =
        await syncHandler.handshake(payload: handshakeRequestPayload);

    print(handshakeResponsePayload.orderedClassNames);

    await syncHandler.disconnect();

    await Future.delayed(Duration(seconds: 120));

    syncHandler.connect();

    final echoRequestPayload2 = EchoRequestPayload(
      message: Uuid().v4(),
    );
    final echoResponsePayload2 = await syncHandler.echo(
      payload: echoRequestPayload2,
    );
    if (echoResponsePayload2.message != echoRequestPayload2.message) {
      throw NetCoreSyncException(
          "Response echoMessage: ${echoResponsePayload2.message} is "
          "different than Request echoMessage: ${echoRequestPayload2.message}");
    }

    await syncHandler.disconnect();
  }
}
