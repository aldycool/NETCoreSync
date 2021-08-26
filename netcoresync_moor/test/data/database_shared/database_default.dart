import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:sqlite3/open.dart';
import '../database.dart';

Future<void> openSqlite() async {
  if (io.Platform.isLinux) {
    final scriptDir = io.File(io.Platform.script.toFilePath()).parent;
    final libraryNextToScript = io.File('${scriptDir.path}/sqlite3.so');
    if (libraryNextToScript.existsSync()) {
      open.overrideFor(OperatingSystem.linux,
          () => ffi.DynamicLibrary.open(libraryNextToScript.path));
    }
  }

  if (io.Platform.isWindows) {
    final scriptDir = io.File(io.Platform.script.toFilePath()).parent;
    final libraryNextToScript = io.File('${scriptDir.path}/sqlite3.dll');
    if (libraryNextToScript.existsSync()) {
      open.overrideFor(OperatingSystem.windows,
          () => ffi.DynamicLibrary.open(libraryNextToScript.path));
    }
  }
}

Future<Database> constructDatabase({
  required String databaseFileLocation,
  bool logStatements = false,
  bool inMemory = true,
}) {
  if (inMemory) {
    return Future.value(Database(VmDatabase.memory(
      logStatements: logStatements,
    )));
  }

  final queryExecutor = LazyDatabase(() async {
    final file = io.File(databaseFileLocation);
    return VmDatabase(file, logStatements: logStatements);
  });
  return Future.value(Database(queryExecutor));
}
