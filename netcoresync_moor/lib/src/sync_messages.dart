import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:archive/archive.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'netcoresync_classes.dart';
import 'netcoresync_knowledges.dart';

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
  connectedNotification, // no payload for this action, only for assertion.
  commandRequest,
  commandResponse,
  handshakeRequest,
  handshakeResponse,
  syncTableRequest,
  syncTableResponse,
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
}

class ResponseMessage {
  String id;
  String action;
  String? errorMessage;
  Map<String, dynamic> payload;

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
  final Map<String, dynamic> customInfo;

  const HandshakeRequestPayload({
    required this.schemaVersion,
    required this.syncIdInfo,
    required this.customInfo,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "schemaVersion": schemaVersion,
      "syncIdInfo": syncIdInfo.toJson(),
      "customInfo": customInfo,
    };
  }
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

class SyncTableRequestPayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.syncTableRequest);

  final String className;
  final Map<String, dynamic> annotations;
  final List<dynamic> unsyncedRows;
  final List<NetCoreSyncKnowledge> knowledges;
  final Map<String, dynamic> customInfo;

  const SyncTableRequestPayload({
    required this.className,
    required this.annotations,
    required this.unsyncedRows,
    required this.knowledges,
    required this.customInfo,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "className": className,
      "annotations": annotations,
      "unsyncedRows": unsyncedRows,
      "knowledges": knowledges.map((model) => model.toJson()).toList(),
      "customInfo": customInfo,
    };
  }
}

class SyncTableResponsePayload extends BasePayload {
  @override
  String get action =>
      EnumToString.convertToString(PayloadActions.syncTableResponse);

  final String className;
  final Map<String, dynamic> annotations;
  final List<dynamic> unsyncedRows;
  final List<NetCoreSyncKnowledge> knowledges;
  final List<String> deletedIds;
  final Map<String, dynamic> logs;

  const SyncTableResponsePayload({
    required this.className,
    required this.annotations,
    required this.unsyncedRows,
    required this.knowledges,
    required this.deletedIds,
    required this.logs,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "className": className,
      "annotations": annotations,
      "unsyncedRows": unsyncedRows,
      "knowledges": knowledges.map((model) => model.toJson()).toList(),
      "deletedIds": deletedIds,
      "logs": logs,
    };
  }

  SyncTableResponsePayload.fromJson(Map<String, dynamic> json)
      : className = json["className"],
        annotations = Map.from(json["annotations"]),
        unsyncedRows = List.from(json["unsyncedRows"]),
        knowledges = List<NetCoreSyncKnowledge>.from(
            (json["knowledges"] as Iterable)
                .map((model) => NetCoreSyncKnowledge.fromJson(model))),
        deletedIds = List.from(json["deletedIds"]),
        logs = Map.from(json["logs"]);
}
