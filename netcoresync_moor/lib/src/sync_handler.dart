import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as socket_channel_status;
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_exceptions.dart';
import 'sync_messages.dart';

class SyncHandler {
  final String url;
  final void Function(Object?)? logger;

  final String _connectionId = Uuid().v4();
  late WebSocketChannel _channel;
  late StreamSubscription _subscription;
  final Map<String, Completer<CompleterResult>> _requests = {};

  bool _connectRequested = false;
  bool _connected = false;
  Completer _completerDone = Completer();

  SyncHandler({
    required this.url,
    this.logger,
  });

  String get connectionId => _connectionId;

  bool get connected => _connected;

  void _throwIfNotConnected() {
    if (!_connectRequested) {
      throw NetCoreSyncException("WebSocket connection is not requested yet");
    }
    if (!_connected) {
      throw NetCoreSyncException("WebSocket is not connected yet");
    }
  }

  void _log(Object? object) {
    if (logger != null) {
      logger!(object);
    }
  }

  void _logConnectionState({
    String? message,
    required String connectionId,
    required bool connectRequested,
    required bool connected,
  }) {
    _log({
      "source": "syncHandler",
      "type": "connectionState",
      "message": message,
      "connectionId": connectionId,
      "connectRequested": connectRequested,
      "connected": connected,
    });
  }

  void connect() {
    if (_connectRequested) {
      throw NetCoreSyncException("WebSocket connection is already requested");
    }
    if (_connected) {
      throw NetCoreSyncException("WebSocket is already connected");
    }
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _connectRequested = true;
    _completerDone = Completer();
    _logConnectionState(
      message: "Client connection requested",
      connectionId: _connectionId,
      connectRequested: _connectRequested,
      connected: _connected,
    );
    _subscription = _channel.stream.listen(
      (message) => _onData(message),
      onError: _onError,
      onDone: () async => await _onDone(),
    );
  }

  void _onData(dynamic message) {
    final response = SyncMessages.decompress(message);

    BasePayload responsePayload;

    if (EnumToString.fromString(PayloadActions.values, response.action) ==
        PayloadActions.handshakeResponse) {
      _connected = true;
      _logConnectionState(
        message: "Client connection opened",
        connectionId: _connectionId,
        connectRequested: _connectRequested,
        connected: _connected,
      );
      responsePayload = HandshakeResponsePayload.fromJson(response.payload);
    } else if (EnumToString.fromString(
            PayloadActions.values, response.action) ==
        PayloadActions.echoResponse) {
      responsePayload = EchoResponsePayload.fromJson(response.payload);
    } else if (EnumToString.fromString(
            PayloadActions.values, response.action) ==
        PayloadActions.delayResponse) {
      responsePayload = DelayResponsePayload.fromJson(response.payload);
    } else if (EnumToString.fromString(
            PayloadActions.values, response.action) ==
        PayloadActions.exceptionResponse) {
      responsePayload = ExceptionResponsePayload.fromJson(response.payload);
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

  void _onError(Object error) {
    _terminateActiveRequests(
      error: error,
    );
  }

  Future<void> _onDone() async {
    _connectRequested = false;
    _connected = false;
    _logConnectionState(
      message: "Client connection closed",
      connectionId: _connectionId,
      connectRequested: _connectRequested,
      connected: _connected,
    );
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

  Future<CompleterResult> handshake(
      {required HandshakeRequestPayload payload}) async {
    if (!_connectRequested) {
      throw NetCoreSyncException("WebSocket connection is not requested yet");
    }
    if (_connected) {
      throw NetCoreSyncException("WebSocket is already connected");
    }
    final request = RequestMessage(
      connectionId: _connectionId,
      basePayload: payload,
    );
    final completer = Completer<CompleterResult>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  Future<void> disconnect() async {
    _throwIfNotConnected();
    await _channel.sink.close(socket_channel_status.goingAway);
    await _completerDone.future;
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

  Future<CompleterResult> delay({required DelayRequestPayload payload}) async {
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

  Future<CompleterResult> exception(
      {required ExceptionRequestPayload payload}) async {
    _throwIfNotConnected();
    if (!payload.raiseOnRemote) {
      throw Exception(payload.errorMessage);
    }
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
        !(errorMessage != null && error != null),
        "Failed completer (indicated with either errorMessage (coming from "
        "Server) or error exception (coming from internals)) cannot have both "
        "errorMessage and error specified. On failed completer, if the "
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
