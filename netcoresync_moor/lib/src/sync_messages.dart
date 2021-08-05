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
  handshakeRequest,
  handshakeResponse,
  echoRequest,
  echoResponse,
  delayRequest,
  delayResponse,
  exceptionRequest,
  exceptionResponse,
  logRequest,
  logResponse,
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

class DelayRequestPayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.delayRequest);

  final int delayInMs;

  const DelayRequestPayload({
    required this.delayInMs,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "delayInMs": delayInMs,
    };
  }

  DelayRequestPayload.fromJson(Map<String, dynamic> json)
      : delayInMs = json["delayInMs"];
}

class DelayResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.delayResponse);

  const DelayResponsePayload();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  DelayResponsePayload.fromJson(Map<String, dynamic> json);
}

class ExceptionRequestPayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.exceptionRequest);

  final bool raiseOnRemote;
  final String errorMessage;

  const ExceptionRequestPayload({
    required this.raiseOnRemote,
    required this.errorMessage,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "raiseOnRemote": raiseOnRemote,
      "errorMessage": errorMessage,
    };
  }

  ExceptionRequestPayload.fromJson(Map<String, dynamic> json)
      : raiseOnRemote = json["raiseOnRemote"],
        errorMessage = json["errorMessage"];
}

class ExceptionResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.exceptionResponse);

  const ExceptionResponsePayload();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  ExceptionResponsePayload.fromJson(Map<String, dynamic> json);
}

class LogRequestPayload extends BasePayload {
  @override
  String get action => EnumToString.convertToString(PayloadActions.logRequest);

  final Map<String, dynamic> log;

  const LogRequestPayload({
    required this.log,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "message": log,
    };
  }

  LogRequestPayload.fromJson(Map<String, dynamic> json)
      : log = Map.from(json["message"]);
}

class LogResponsePayload extends BasePayload {
  @override
  String get action => EnumToString.convertToString(PayloadActions.logResponse);

  const LogResponsePayload();

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  LogResponsePayload.fromJson(Map<String, dynamic> json);
}
