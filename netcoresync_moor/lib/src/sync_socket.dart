import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_classes.dart';
import 'netcoresync_exceptions.dart';
import 'sync_messages.dart';

class SyncSocket {
  static const String defaultErrorMessageStillWaitingConnection =
      "Socket is still waiting for connection";
  static const String defaultErrorMessageSocketNotConnected =
      "Socket is not connected yet";
  static const String defaultErrorMessageSocketAlreadyConnected =
      "Socket is already connected";

  final String url;
  final void Function(Object?)? logger;

  late WebSocketChannel _channel;
  bool _waitingConnection = false;
  late Completer<ConnectResult> _waitingConnectionCompleter;
  String? _connectionId;
  final Map<String, Completer<ResponseResult>> _requests = {};
  Completer? _onDoneCompleter;

  SyncSocket({
    required this.url,
    this.logger,
  });

  void _log(Object? object) {
    if (logger != null) {
      logger!(object);
    }
  }

  void _logConnectionState({
    required String connectionId,
    required bool connected,
  }) {
    _log({
      "type": "ConnectionState",
      "connectionId": connectionId,
      "state": connected ? "Open" : "Closed",
    });
  }

  void _logStreamEvent({
    String? connectionId,
    required String name,
    String? action,
    Object? error,
  }) {
    var log = <String, Object?>{
      "type": "StreamEvent",
      "connectionId": connectionId,
      "name": name,
    };
    if (action != null) {
      log["action"] = action;
    }
    if (error != null) {
      log["error"] = error;
    }
    _log(log);
  }

  void _logLocalCommand({
    required String connectionId,
    required String data,
    required bool finished,
  }) {
    _log({
      "type": "LocalCommand",
      "connectionId": connectionId,
      "data": data,
      "state": finished ? "Finished" : "Started",
    });
  }

  bool get connected => _connectionId != null;

  void _throwIfNotReady() {
    if (_waitingConnection) {
      throw NetCoreSyncSocketException(
          defaultErrorMessageStillWaitingConnection);
    }
    if (!connected) {
      throw NetCoreSyncSocketException(defaultErrorMessageSocketNotConnected);
    }
  }

  Future<ConnectResult> connect() {
    if (_waitingConnection) {
      throw NetCoreSyncSocketException(
          defaultErrorMessageStillWaitingConnection);
    }
    if (_connectionId != null) {
      throw NetCoreSyncSocketException(
          defaultErrorMessageSocketAlreadyConnected);
    }
    _waitingConnection = true;
    _waitingConnectionCompleter = Completer<ConnectResult>();
    _onDoneCompleter = Completer();
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.stream.listen(
      _onData,
      onError: (error) async => _onError(error),
      onDone: _onDone,
    );
    return _waitingConnectionCompleter.future;
  }

  void _onData(dynamic message) {
    final response = SyncMessages.decompress(message);
    _logStreamEvent(
      connectionId: _connectionId,
      name: "onData",
      action: response.action,
    );
    if (_waitingConnection) {
      assert(response.action ==
          EnumToString.convertToString(PayloadActions.connectedNotification));
      _connectionId = response.id;
      _waitingConnectionCompleter.complete(ConnectResult(
        connectionId: _connectionId,
      ));
      _waitingConnection = false;
      _logConnectionState(connectionId: _connectionId!, connected: true);
      return;
    }
    BasePayload responsePayload;
    if (response.action ==
        EnumToString.convertToString(PayloadActions.commandResponse)) {
      responsePayload = CommandResponsePayload.fromJson(response.payload);
    } else if (response.action ==
        EnumToString.convertToString(PayloadActions.handshakeResponse)) {
      responsePayload = HandshakeResponsePayload.fromJson(response.payload);
    } else if (response.action ==
        EnumToString.convertToString(PayloadActions.syncTableResponse)) {
      responsePayload = SyncTableResponsePayload.fromJson(response.payload);
    } else {
      throw NetCoreSyncSocketException(
          "Unexpected response action: ${response.action}");
    }
    if (_requests.containsKey(response.id)) {
      _requests[response.id]!.complete(ResponseResult(
        errorMessage: response.errorMessage,
        payload: responsePayload,
      ));
      _requests.remove(response.id);
    }
  }

  Future<void> _onError(Object error) async {
    _logStreamEvent(
      connectionId: _connectionId,
      name: "onError",
      error: error,
    );
    if (_waitingConnection) {
      // This is usually caused by: 1. wrong url, 2. correct url but wrong path,
      // 3. the client network is unstable, 4. the server is down, 5. the server
      // network is unstable.
      _waitingConnectionFailed(error: error);
      return;
    }
    // This code path is actually never been reached. The documentation suggests
    // that we can trap the sink.addError() call here, but it just throws on
    // the current Zone.
    _terminateActiveRequests(error: error);
    await close();
  }

  void _onDone() {
    _logStreamEvent(
      connectionId: _connectionId,
      name: "onDone",
    );
    if (_waitingConnection) {
      // This is usually caused by: 1. when client successfully connected to the
      // server, but not yet received the ConnectedNotificationPayload from the
      // server (probably the network is disrupted), 2. Exceptions happens on
      // the server while processing the client connection
      _waitingConnectionFailed(errorMessage: ConnectResult.defaultErrorMessage);
      return;
    }
    _terminateActiveRequests(errorMessage: ResponseResult.defaultErrorMessage);
    String logConnectionId = _connectionId ?? "null";
    _connectionId = null;
    if (_onDoneCompleter != null && !_onDoneCompleter!.isCompleted) {
      _onDoneCompleter!.complete();
    }
    _logConnectionState(connectionId: logConnectionId, connected: false);
  }

  void _waitingConnectionFailed({
    String? errorMessage,
    Object? error,
  }) {
    _waitingConnectionCompleter.complete(
      ConnectResult(
        errorMessage: errorMessage,
        error: error,
      ),
    );
    _waitingConnection = false;
  }

  void _terminateActiveRequests({
    String? errorMessage,
    Object? error,
  }) {
    assert(errorMessage != null || error != null);
    if (_requests.isNotEmpty) {
      for (var item in _requests.entries) {
        if (!item.value.isCompleted) {
          ResponseResult responseResult = ResponseResult(
            errorMessage: errorMessage,
            error: error,
          );
          item.value.complete(responseResult);
        }
      }
      _requests.clear();
    }
  }

  Future<dynamic> close() async {
    if (connected) {
      await _channel.sink.close();
      if (_onDoneCompleter != null) {
        return _onDoneCompleter!.future;
      }
    }
    return Future.value();
  }

  Future<ResponseResult> request({required BasePayload payload}) {
    _throwIfNotReady();
    _handleLocalCommandRequestPayload(payload);
    final request = RequestMessage(
      connectionId: _connectionId!,
      basePayload: payload,
    );
    final completer = Completer<ResponseResult>();
    _requests[request.id] = completer;
    _channel.sink.add(SyncMessages.compress(request));
    return completer.future;
  }

  Future _handleLocalCommandRequestPayload(
    BasePayload payload,
  ) async {
    if (payload.action ==
        EnumToString.convertToString(PayloadActions.commandRequest)) {
      final requestPayload = CommandRequestPayload.fromJson(payload.toJson());
      if (requestPayload.data.containsKey("executeOnLocal") &&
          requestPayload.data["executeOnLocal"] &&
          requestPayload.data.containsKey("commandName")) {
        String commandName = requestPayload.data["commandName"];
        if (commandName == "delay") {
          int delayInMs = int.tryParse(requestPayload.data["delayInMs"]) ?? 0;
          _logLocalCommand(
            connectionId: _connectionId ?? "",
            data: "commandName: $commandName, delayInMs: $delayInMs",
            finished: false,
          );
          await Future.delayed(Duration(milliseconds: delayInMs));
          _logLocalCommand(
            connectionId: _connectionId ?? "",
            data: "commandName: $commandName, delayInMs: $delayInMs",
            finished: true,
          );
        }
        if (commandName == "exception") {
          String commandErrorMessage =
              requestPayload.data["errorMessage"] ?? "null";
          _logLocalCommand(
            connectionId: _connectionId ?? "",
            data:
                "commandName: $commandName, errorMessage: $commandErrorMessage",
            finished: false,
          );
          throw Exception(commandErrorMessage);
        }
      }
    }
  }
}

class ConnectResult {
  static const String defaultErrorMessage = "Error while connecting to server. "
      "Please check your network connection, or try again later.";

  String? errorMessage;
  Object? error;
  String? connectionId;

  ConnectResult({
    this.errorMessage,
    this.error,
    this.connectionId,
  }) {
    assert((connectionId != null && errorMessage == null && error == null) ||
        (connectionId == null && (errorMessage != null || error != null)));
    if (errorMessage == null && error != null) {
      errorMessage = defaultErrorMessage;
    }
  }
}

class ResponseResult {
  static const String defaultErrorMessage = "Error while commmunicating with "
      "the server. Please check your network connection, or try again later.";
  static const String payloadNullErrorMessage = "No data received from the "
      "server. Please try again later.";

  String? errorMessage;
  Object? error;
  BasePayload? payload;

  ResponseResult({
    this.errorMessage,
    this.error,
    this.payload,
  }) {
    assert(
        !(errorMessage != null && error != null),
        "Failed response (indicated with either errorMessage (coming from "
        "Server) or error exception (coming from internals)) cannot have both "
        "errorMessage and error specified. On failed response, if the "
        "errorMessage is null and the error exception is not, then the "
        "errorMessage will be taken from the error exception's message. This "
        "is just for convenience during development. In production, error "
        "exception should be checked first whether it carries sensitive "
        "information to be presented to the end-users or not.");
    if (errorMessage == null && error != null) {
      errorMessage = error.toString();
    } else if (errorMessage != null && error == null) {
      try {
        Map<String, dynamic> serverError = jsonDecode(errorMessage!);
        if (serverError.containsKey("type") &&
            serverError["type"] == "NetCoreSyncServerException") {
          String message = serverError["message"];
          error = NetCoreSyncServerException(message);
          errorMessage = null;
        } else if (serverError.containsKey("type") &&
            serverError["type"] ==
                "NetCoreSyncServerSyncIdInfoOverlappedException") {
          List<dynamic> overlappedSyncIdsMap = serverError["overlappedSyncIds"];
          List<String> overlappedSyncIds = [];
          for (var item in overlappedSyncIdsMap) {
            final list = SyncIdInfo.fromJson(item).getAllSyncIds(enclosure: "");
            for (var syncId in list) {
              if (!overlappedSyncIds.contains(syncId)) {
                overlappedSyncIds.add(syncId);
              }
            }
          }
          error =
              NetCoreSyncServerSyncIdInfoOverlappedException(overlappedSyncIds);
          errorMessage = null;
        }
      } catch (_) {}
    }
  }
}
