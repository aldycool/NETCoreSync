import 'package:moor/moor_web.dart';
import '../database.dart';

Future<void> openSqlite() {
  // No special action needed for web
  return Future.value();
}

Future<String> getDatabaseFileLocation() {
  String storageType = "";
  //storageType = "LocalStorage";
  storageType = "IndexedDb";
  storageType += "|${Database.fileName}";
  return Future.value(storageType);
}

Future<Database> constructDatabase({bool logStatements = false}) async {
  String fileLocation = await getDatabaseFileLocation();
  String storageType = fileLocation.split("|")[0];
  String fileName = fileLocation.split("|")[1];
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
