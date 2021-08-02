import 'dart:async';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as socket_channel_status;
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_exceptions.dart';
import 'sync_messages.dart';

class SyncHandler {
  final String url;

  late WebSocketChannel _channel;
  late StreamSubscription _subscription;
  final Map<String, Completer<BasePayload>> _requests = {};

  bool _connected = false;
  Completer _completerDone = Completer();

  SyncHandler({
    required this.url,
  });

  void _throwIfNotConnected() {
    if (!_connected) {
      throw NetCoreSyncException("WebSocket is not connected yet");
    }
  }

  void connect() {
    if (_connected) {
      throw NetCoreSyncException("WebSocket is already connected");
    }

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _connected = true;
    _completerDone = Completer();
    _log("Client Opened");
    _subscription = _channel.stream.listen(
      (message) => _onData(message),
      onDone: () async => await _onDone(),
    );
  }

  Future<void> _onDone() async {
    _log("Client Closed");
    _connected = false;
    await _subscription.cancel();
    _requests.clear();
    if (!_completerDone.isCompleted) {
      _completerDone.complete();
    }
  }

  Future<void> disconnect() async {
    _throwIfNotConnected();
    await _channel.sink.close(socket_channel_status.goingAway);
    await _completerDone.future;
  }

  Future<EchoResponsePayload> echo(
      {EchoRequestPayload payload =
          const EchoRequestPayload(message: "This is an echo message")}) async {
    _throwIfNotConnected();
    final request = RequestMessage(
      basePayload: payload,
    );
    final completer = Completer<EchoResponsePayload>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  Future<HandshakeResponsePayload> handshake(
      {required HandshakeRequestPayload payload}) async {
    _throwIfNotConnected();
    final request = RequestMessage(
      basePayload: payload,
    );
    final completer = Completer<HandshakeResponsePayload>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  void _onData(dynamic message) {
    final response = SyncMessages.decompress(message);

    BasePayload responsePayload;

    if (EnumToString.fromString(PayloadActions.values, response.action) ==
        PayloadActions.echoResponse) {
      responsePayload = EchoResponsePayload.fromJson(response.payload);
    } else if (EnumToString.fromString(
            PayloadActions.values, response.action) ==
        PayloadActions.handshakeResponse) {
      responsePayload = HandshakeResponsePayload.fromJson(response.payload);
    } else {
      throw NetCoreSyncException(
          "Unexpected response action: ${response.action}");
    }

    if (_requests.containsKey(response.id)) {
      _requests[response.id]!.complete(responsePayload);
      _requests.remove(response.id);
    }
  }

  void _log(Object? object) {
    print(object);
  }
}
