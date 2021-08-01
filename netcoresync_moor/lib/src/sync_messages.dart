import 'dart:convert';
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
  String action;
  int schemaVersion;
  SyncIdInfo syncIdInfo;
  Map<String, dynamic> payload;

  RequestMessage({
    required this.schemaVersion,
    required this.syncIdInfo,
    required BasePayload basePayload,
  })  : action = basePayload.action,
        payload = basePayload.toJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "action": action,
      "schemaVersion": schemaVersion,
      "syncIdInfo": syncIdInfo.toJson(),
      "payload": payload,
    };
  }

  RequestMessage.fromJson(Map<String, dynamic> json)
      : action = json["action"],
        schemaVersion = json["schemaVersion"],
        syncIdInfo = SyncIdInfo.fromJson(json["syncIdInfo"]),
        payload = Map.from(json["payload"]);
}

class ResponseMessage {
  String action;
  bool isOk;
  String? errorMessage;
  Map<String, dynamic> payload;

  ResponseMessage({
    required this.isOk,
    this.errorMessage,
    required BasePayload basePayload,
  })  : action = basePayload.action,
        payload = basePayload.toJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "action": action,
      "isOk": isOk,
      "errorMessage": errorMessage,
      "payload": payload,
    };
  }

  ResponseMessage.fromJson(Map<String, dynamic> json)
      : action = json["action"],
        isOk = json["isOk"],
        errorMessage = json["errorMessage"],
        payload = Map.from(json["payload"]);
}

abstract class BasePayload {
  String get action;
  Map<String, dynamic> toJson();
}

class EchoRequestPayload extends BasePayload {
  @override
  String get action => EnumToString.convertToString(PayloadActions.echoRequest);

  String message;

  EchoRequestPayload({
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

  String message;

  EchoResponsePayload({
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

  HandshakeRequestPayload();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  HandshakeRequestPayload.fromJson(Map<String, dynamic> json);
}

class HandshakeResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.handshakeResponse);

  List<String> orderedClassNames;

  HandshakeResponsePayload({
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
