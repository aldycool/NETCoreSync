// import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import 'package:moor/moor.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'netcoresync_client.dart';
import 'netcoresync_exceptions.dart';
import 'netcoresync_knowledges.dart';
import 'data_access.dart';

class SyncHandler {
  final DataAccess dataAccess;

  SyncHandler(this.dataAccess);

  Future<void> synchronize({
    required String synchronizationId,
    required String url,
    SynchronizeDirection synchronizeDirection =
        SynchronizeDirection.pushThenPull,
    Map<String, dynamic> customInfo = const {},
  }) async {
    if (dataAccess.inTransaction()) {
      throw NetCoreSyncMustNotInsideTransactionException();
    }

    List<String> logs = [];

    await dataAccess.database.transaction(() async {
      List<String> ensureLogs =
          await dataAccess.ensureAllTableTimeStampsAreValid();
      logs.addAll(ensureLogs);
    });

    List<NetCoreSyncKnowledge> sourceKnowledges =
        await dataAccess.getKnowledges();

    var httpClient = http.Client();
    try {
      Map<String, dynamic> payload = {
        "PayloadAction": "Knowledge",
        "SynchronizationId": synchronizationId,
        "CustomInfo": customInfo,
      };
      String jsonString = jsonEncode(payload);

      // The .NET Core Server Side uses the "Unicode" encoding (not UTF8), the following make sure the string is encoded to "UTF16 Little Endian" to be compatible with the server side.
      // String to UTF16LE taken from: https://stackoverflow.com/questions/68089811/how-to-encode-to-utf16-little-endian-in-dart
      List<int> codeUnits = jsonString.codeUnits;
      var utf16le = ByteData(codeUnits.length * 2);
      for (var i = 0; i < codeUnits.length; i++) {
        utf16le.setUint16(i * 2, codeUnits[i], Endian.little);
      }
      final uint8Bytes = utf16le.buffer.asUint8List().toList();

      List<int> bytes = List.from(uint8Bytes);
      List<int> compressed = GZipEncoder().encode(bytes) as List<int>;
      var multipartRequest = http.MultipartRequest("POST", Uri.parse(url));
      multipartRequest.files.add(http.MultipartFile.fromBytes(
        "files",
        compressed,
        filename: "compressed.dat",
      ));
      final httpStreamResponse = await httpClient.send(multipartRequest);
      final httpResponse = await http.Response.fromStream(httpStreamResponse);
      Map<String, dynamic> decoded = jsonDecode(httpResponse.body);
      if (decoded.containsKey("payload")) {
        String base64Str = decoded["payload"];
        final uint8List = base64.decode(base64Str);
        final unzipped = GZipDecoder().decodeBytes(uint8List.toList());
        var blob = ByteData.sublistView(Uint8List.fromList(unzipped));
        List<int> charCodes = [];
        for (var i = 0; i < blob.lengthInBytes; i += 2) {
          charCodes.add(blob.getUint16(i, Endian.little));
        }
        // debugger();
        final payloadStr = String.fromCharCodes(charCodes);
        Map<String, dynamic> payload = jsonDecode(payloadStr);
        print(payload);
      }
      print(httpResponse);
    } finally {
      httpClient.close();
    }
  }
}
