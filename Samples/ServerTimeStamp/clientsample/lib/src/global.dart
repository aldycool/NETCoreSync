import 'data/database.dart';

class Global {
  Global._();
  static final Global instance = Global._();

  late Database database;

  void setDatabase(Database database) {
    this.database = database;
  }
}
