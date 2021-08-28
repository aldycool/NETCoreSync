import 'dart:io' as io;
import 'package:moor/moor.dart';
import 'package:moor/ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';

part 'main.g.dart';

// The following is just an example of how to "syntactically" use the library,
// technically the example won't synchronize correctly because the server-side
// component needs to be configured first. For more complete example, visit the
// project example on:
// https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/clientsample

@NetCoreSyncTable()
class Employees extends Table {
  TextColumn get id =>
      text().withLength(max: 36).clientDefault(() => Uuid().v4())();
  TextColumn get name => text()();
  DateTimeColumn get birthday =>
      dateTime().clientDefault(() => DateTime.now())();

  // these are the "synchronization" fields
  TextColumn get syncId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  TextColumn get knowledgeId =>
      text().withLength(max: 36).withDefault(Constant(""))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {
        id,
      };
}

@UseMoor(
  tables: [
    Employees,
    NetCoreSyncKnowledges,
  ],
)
class MyDatabase extends _$MyDatabase
    with NetCoreSyncClient, NetCoreSyncClientUser {
  MyDatabase(QueryExecutor queryExecutor) : super(queryExecutor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
      );
}

void main() async {
  final myDatabase = MyDatabase(LazyDatabase(() async {
    final file = io.File("my_database_file.db");
    return VmDatabase(file, logStatements: true);
  }));
  await myDatabase.netCoreSyncInitialize();

  // The server-side setup needs to be configured first, or else the
  // synchronization will fail. For more complete example, visit the project
  // example on:
  // https://github.com/aldycool/NETCoreSync/tree/master/Samples/ServerTimeStamp/clientsample
  await myDatabase.netCoreSyncSynchronize(
      url: "wss://localhost:5001/netcoresyncserver");
}
