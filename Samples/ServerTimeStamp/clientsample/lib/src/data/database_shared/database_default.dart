import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import '../database.dart';

Future<void> openSqlite() async {
  if (io.Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }

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

Future<String> getDatabaseFileLocation() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final fileName = join(dbFolder.path, Database.fileName);
  return fileName;
}

Future<Database> constructDatabase({bool logStatements = false}) {
  final queryExecutor = LazyDatabase(() async {
    final fileLocation = await getDatabaseFileLocation();
    final file = io.File(fileLocation);
    return VmDatabase(file, logStatements: logStatements);
  });
  return Future.value(Database(queryExecutor));
}
