import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import 'netcoresync_knowledges.dart';
import 'netcoresync_exceptions.dart';

part 'database.g.dart';

@UseMoor(tables: [
  NetCoreSyncKnowledges,
])
class Database extends _$Database {
  late final int _schemaVersion;

  Database({
    required QueryExecutor queryExecutor,
    required int schemaVersion,
  }) : super(queryExecutor) {
    _schemaVersion = schemaVersion;
  }

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          throw NetCoreSyncShouldNotPerformCreateMigrationException();
        },
      );
}
