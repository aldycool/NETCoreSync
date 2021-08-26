import 'dart:async';
import 'dart:io' as io;
import 'dart:ffi' as ffi;
import 'package:sqlite3/open.dart';
import 'package:path/path.dart' as path;
import 'package:version/version.dart';
import '../data/database.dart';

class Helper {
  static Future<Database> setUpDatabase({
    String testFilesFolder = ".test_files",
    String databaseFileName = "netcoresync_moor_test.db",
    bool useInMemoryDatabase = true,
    bool logSqlStatements = false,
  }) async {
    final testDirectory = io.Directory(testFilesFolder);
    if (testDirectory.existsSync()) testDirectory.deleteSync(recursive: true);

    openSqlite();

    // Override for macos is defined here (not inside the openSqlite() method),
    // this is due to the need to support recent "insertReturning" of sqlite3
    if (io.Platform.isMacOS) {
      final rootDir = io.Directory.current.path;
      final overrideSqliteLib = path.join(
          rootDir, "test", "dylib", "sqlite3", "macos", "libsqlite3.dylib");
      open.overrideFor(OperatingSystem.macOS,
          () => ffi.DynamicLibrary.open(overrideSqliteLib));
    }

    // The .test_files folder will be created (if useInMemoryDatabase = false)
    // in the root folder (same folder as pubspec.yaml).
    Database database = await constructDatabase(
      databaseFileLocation: path.join(testFilesFolder, databaseFileName),
      logStatements: logSqlStatements,
      inMemory: useInMemoryDatabase,
    );
    return database;
  }

  static Future<void> clearAllData(Database database) async {
    // Order of the deletion is important to avoid foreign key constraint
    await database.delete(database.persons).go();
    await database.delete(database.areas).go();
    await database.delete(database.customObjects).go();
    await database.delete(database.netCoreSyncKnowledges).go();
  }

  static Future<void> tearDownDatabase(
    Database database, {
    String testFilesFolder = ".test_files",
  }) async {
    await database.close();
    final testDirectory = io.Directory(testFilesFolder);
    if (testDirectory.existsSync()) testDirectory.deleteSync(recursive: true);
  }

  static Future<Version> getLibraryVersion({
    String testFilesFolder = ".test_files",
    String databaseFileName = "netcoresync_moor_test.db",
    bool useInMemoryDatabase = true,
    bool logSqlStatements = false,
  }) async {
    Database database = await setUpDatabase(
      testFilesFolder: testFilesFolder,
      databaseFileName: databaseFileName,
      useInMemoryDatabase: useInMemoryDatabase,
      logSqlStatements: logSqlStatements,
    );
    Version libraryVersion = Version.parse(
        (await database.customSelect("SELECT sqlite_version() AS ver").get())[0]
            .data["ver"]);
    await tearDownDatabase(database);
    return libraryVersion;
  }

  static dynamic shouldSkip(
    Version currentVersion,
    Version requiredVersion, {
    String moreInfo = "",
  }) {
    if (currentVersion < requiredVersion) {
      return "Test is skipped due to the current sqlite3 version: "
          "($currentVersion) is less than the required version: ($requiredVersion)."
          "${moreInfo.isNotEmpty ? " " + moreInfo : ""}";
    }
    return null;
  }

  static void bypassHttpCertificateVerifyFailed() {
    io.HttpOverrides.global = _CustomHttpOverrides();
  }
}

class _CustomHttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (io.X509Certificate cert, String host, int port) => true;
  }
}
