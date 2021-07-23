import 'package:moor/moor_web.dart';
import '../database.dart';

Future<void> openSqlite() {
  // No special action needed for web
  return Future.value();
}

Future<Database> constructDatabase({
  required String databaseFileLocation,
  bool logStatements = false,
  bool inMemory = true,
}) async {
  if (inMemory) {
    throw Exception(
        "At per writing, In-Memory Database is only supported on Android, iOS, and MacOS");
  }

  String storageType = databaseFileLocation.split("|")[0];
  String fileName = databaseFileLocation.split("|")[1];
  if (storageType == "LocalStorage") {
    WebDatabase webDatabase =
        WebDatabase(fileName, logStatements: logStatements);
    return Database(webDatabase);
  }
  if (storageType == "IndexedDb") {
    WebDatabase webDatabase = WebDatabase.withStorage(
        await MoorWebStorage.indexedDbIfSupported(fileName));
    return Database(webDatabase);
  }
  throw UnimplementedError();
}
