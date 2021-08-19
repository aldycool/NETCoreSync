export 'database_shared/database_stub.dart'
    if (dart.library.html) 'database_shared/database_web.dart'
    if (dart.library.io) 'database_shared/database_default.dart';
