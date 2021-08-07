import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:archive/archive.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_classes.dart';

class SyncMessages {
  static List<int> compress(RequestMessage requestMessage) {
    String jsonRequest = jsonEncode(requestMessage);
    List<int> jsonRequestBytes = utf8.encode(jsonRequest);
    List<int> jsonRequestGzip =
        GZipEncoder().encode(jsonRequestBytes) as List<int>;
    return jsonRequestGzip;
  }

  static ResponseMessage decompress(dynamic message) {
    List<int> responseBytes = GZipDecoder().decodeBytes(message);
    String decodedMessage = utf8.decode(responseBytes);
    ResponseMessage result =
        ResponseMessage.fromJson(jsonDecode(decodedMessage));
    return result;
  }
}

enum PayloadActions {
  connectedNotification,
  commandRequest,
  commandResponse,
  handshakeRequest,
  handshakeResponse,
}

class RequestMessage {
  String connectionId;
  String id;
  String action;
  Map<String, dynamic> payload;

  RequestMessage({
    required this.connectionId,
    required BasePayload basePayload,
  })  : id = Uuid().v4(),
        action = basePayload.action,
        payload = basePayload.toJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "connectionId": connectionId,
      "id": id,
      "action": action,
      "payload": payload,
    };
  }

  RequestMessage.fromJson(Map<String, dynamic> json)
      : connectionId = json["connectionId"],
        id = json["id"],
        action = json["action"],
        payload = Map.from(json["payload"]);
}

class ResponseMessage {
  String id;
  String action;
  String? errorMessage;
  Map<String, dynamic> payload;

  ResponseMessage({
    required this.id,
    this.errorMessage,
    required BasePayload basePayload,
  })  : action = basePayload.action,
        payload = basePayload.toJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "action": action,
      "errorMessage": errorMessage,
      "payload": payload,
    };
  }

  ResponseMessage.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        action = json["action"],
        errorMessage = json["errorMessage"],
        payload = Map.from(json["payload"]);
}

abstract class BasePayload {
  String get action;
  Map<String, dynamic> toJson();

  const BasePayload();
}

class ConnectedNotificationPayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.connectedNotification);

  const ConnectedNotificationPayload();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  ConnectedNotificationPayload.fromJson(Map<String, dynamic> json);
}

class CommandRequestPayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.commandRequest);

  final Map<String, dynamic> data;

  const CommandRequestPayload({
    required this.data,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "data": data,
    };
  }

  CommandRequestPayload.fromJson(Map<String, dynamic> json)
      : data = Map.from(json["data"]);
}

class CommandResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.commandResponse);

  final Map<String, dynamic> data;

  const CommandResponsePayload({
    required this.data,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "data": data,
    };
  }

  CommandResponsePayload.fromJson(Map<String, dynamic> json)
      : data = Map.from(json["data"]);
}

class HandshakeRequestPayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.handshakeRequest);

  final int schemaVersion;
  final SyncIdInfo syncIdInfo;

  const HandshakeRequestPayload({
    required this.schemaVersion,
    required this.syncIdInfo,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "schemaVersion": schemaVersion,
      "syncIdInfo": syncIdInfo.toJson(),
    };
  }

  HandshakeRequestPayload.fromJson(Map<String, dynamic> json)
      : schemaVersion = json["schemaVersion"],
        syncIdInfo = SyncIdInfo.fromJson(json["syncIdInfo"]);
}

class HandshakeResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.handshakeResponse);

  final List<String> orderedClassNames;

  const HandshakeResponsePayload({
    required this.orderedClassNames,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "orderedClassNames": orderedClassNames,
    };
  }

  HandshakeResponsePayload.fromJson(Map<String, dynamic> json)
      : orderedClassNames = List.from(json["orderedClassNames"]);
}
