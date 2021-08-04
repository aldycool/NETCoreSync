import 'dart:async';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as socket_channel_status;
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_exceptions.dart';
import 'sync_messages.dart';

class SyncHandler {
  final String url;

  final String _connectionId = Uuid().v4();
  late WebSocketChannel _channel;
  late StreamSubscription _subscription;
  final Map<String, Completer<CompleterResult>> _requests = {};

  bool _connected = false;
  Completer _completerDone = Completer();

  SyncHandler({
    required this.url,
  });

  bool get connected => _connected;

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
    _log("Client Opened, connectionId: $_connectionId");
    _subscription = _channel.stream.listen(
      (message) => _onData(message),
      onError: (error) {
        _terminateActiveRequests(
          error: error,
        );
      },
      onDone: () async => await _onDone(),
    );
  }

  Future<void> _onDone() async {
    _log("Client Closed, connectionId: $_connectionId");
    _connected = false;
    await _subscription.cancel();
    _terminateActiveRequests(
      errorMessage: "Server is unresponsive by an unknown reason",
    );
    if (!_completerDone.isCompleted) {
      _completerDone.complete();
    }
  }

  void _terminateActiveRequests({
    String? errorMessage,
    Object? error,
  }) {
    assert(errorMessage != null || error != null);
    if (_requests.isNotEmpty) {
      for (var item in _requests.entries) {
        if (!item.value.isCompleted) {
          CompleterResult errorCompleterResult = CompleterResult(
            errorMessage: errorMessage,
            error: error,
          );
          item.value.complete(errorCompleterResult);
        }
      }
      _requests.clear();
    }
  }

  Future<void> disconnect() async {
    _throwIfNotConnected();
    await _channel.sink.close(socket_channel_status.goingAway);
    await _completerDone.future;
  }

  Future<CompleterResult> handshake(
      {required HandshakeRequestPayload payload}) async {
    _throwIfNotConnected();
    final request = RequestMessage(
      connectionId: _connectionId,
      basePayload: payload,
    );
    final completer = Completer<CompleterResult>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  Future<CompleterResult> echo(
      {EchoRequestPayload payload =
          const EchoRequestPayload(message: "This is an echo message")}) async {
    _throwIfNotConnected();
    final request = RequestMessage(
      connectionId: _connectionId,
      basePayload: payload,
    );
    final completer = Completer<CompleterResult>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  Future<CompleterResult> log({required LogRequestPayload payload}) async {
    _throwIfNotConnected();
    final request = RequestMessage(
      connectionId: _connectionId,
      basePayload: payload,
    );
    final completer = Completer<CompleterResult>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  void _onData(dynamic message) {
    final response = SyncMessages.decompress(message);

    BasePayload responsePayload;

    if (EnumToString.fromString(PayloadActions.values, response.action) ==
        PayloadActions.handshakeResponse) {
      responsePayload = HandshakeResponsePayload.fromJson(response.payload);
    } else if (EnumToString.fromString(
            PayloadActions.values, response.action) ==
        PayloadActions.echoResponse) {
      responsePayload = EchoResponsePayload.fromJson(response.payload);
    } else if (EnumToString.fromString(
            PayloadActions.values, response.action) ==
        PayloadActions.logResponse) {
      responsePayload = LogResponsePayload.fromJson(response.payload);
    } else {
      throw NetCoreSyncException(
          "Unexpected response action: ${response.action}");
    }

    if (_requests.containsKey(response.id)) {
      _requests[response.id]!.complete(CompleterResult(
        errorMessage: response.errorMessage,
        payload: responsePayload,
      ));
      _requests.remove(response.id);
    }
  }

  void _log(Object? object) {
    print(object);
  }
}

class CompleterResult {
  String? errorMessage;
  Object? error;
  BasePayload? payload;

  CompleterResult({
    this.errorMessage,
    this.error,
    this.payload,
  }) {
    assert(
        (payload != null && errorMessage == null && error == null) ||
            (payload == null && (errorMessage != null || error != null)),
        "It's either a successful completer (indicated by payload without "
        "errorMessage or error exception) or a failed completer (indicated "
        "with null payload with either errorMessage (coming from Server) or "
        "error exception (coming from internals)). On failed completer, if the "
        "errorMessage is null and the error exception is not, then the "
        "errorMessage will be taken from the error exception's message. This "
        "is just for convenience during development. In production, error "
        "exception should be checked first whether it carries sensitive "
        "information to be presented to the end-users or not.");
    if (errorMessage == null && error != null) {
      errorMessage = error.toString();
    }
  }
}
