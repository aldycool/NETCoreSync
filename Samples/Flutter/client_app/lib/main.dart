import 'package:flutter/material.dart';
import 'package:netcoresync_moor/netcoresync_moor.dart';
import 'src/data/database.dart';
import 'src/global.dart';
import 'src/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openSqlite();
  Database database = await constructDatabase();
  Global.instance.setDatabase(database);
  NetCoreSyncClient netCoreSyncClient = await NetCoreSyncClient.initialize(
    generatedDatabase: database,
  );
  Global.instance.setNetCoreSyncClient(netCoreSyncClient);
  database.testConcepts();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
