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
  echoRequest,
  echoResponse,
  handshakeRequest,
  handshakeResponse,
}

class RequestMessage {
  String id;
  String action;
  Map<String, dynamic> payload;

  RequestMessage({
    required BasePayload basePayload,
  })  : id = Uuid().v4(),
        action = basePayload.action,
        payload = basePayload.toJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "action": action,
      "payload": payload,
    };
  }

  RequestMessage.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        action = json["action"],
        payload = Map.from(json["payload"]);
}

class ResponseMessage {
  String id;
  String action;
  bool isOk;
  String? errorMessage;
  Map<String, dynamic> payload;

  ResponseMessage({
    required this.id,
    required this.isOk,
    this.errorMessage,
    required BasePayload basePayload,
  })  : action = basePayload.action,
        payload = basePayload.toJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "action": action,
      "isOk": isOk,
      "errorMessage": errorMessage,
      "payload": payload,
    };
  }

  ResponseMessage.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        action = json["action"],
        isOk = json["isOk"],
        errorMessage = json["errorMessage"],
        payload = Map.from(json["payload"]);
}

abstract class BasePayload {
  String get action;
  Map<String, dynamic> toJson();

  const BasePayload();
}

class EchoRequestPayload extends BasePayload {
  @override
  String get action => EnumToString.convertToString(PayloadActions.echoRequest);

  final String message;

  const EchoRequestPayload({
    required this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "message": message,
    };
  }

  EchoRequestPayload.fromJson(Map<String, dynamic> json)
      : message = json["message"];
}

class EchoResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.echoResponse);

  final String message;

  const EchoResponsePayload({
    required this.message,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "message": message,
    };
  }

  EchoResponsePayload.fromJson(Map<String, dynamic> json)
      : message = json["message"];
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
