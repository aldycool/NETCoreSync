import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'areas.dart';
import 'persons.dart';
import 'custom_objects.dart';

export 'database_shared.dart';

part 'database.g.dart';

@UseMoor(
  tables: [
    Areas,
    Persons,
    CustomObjects,
    NetCoreSyncKnowledges,
  ],
)
class Database extends _$Database
    with NetCoreSyncClient, NetCoreSyncClientUser {
  Database(QueryExecutor queryExecutor) : super(queryExecutor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (openingDetails) async {
          await this.customStatement("PRAGMA foreign_keys = ON");
        },
        onCreate: (Migrator m) {
          return m.createAll();
        },
      );
}
