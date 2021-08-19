import 'package:flutter/material.dart';
import 'src/data/database.dart';
import 'src/global.dart';
import 'src/utils.dart';
import 'src/ui/signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // This is for DEVELOPMENT ONLY, to bypass checks for http certificates
  Utils.bypassHttpCertificateVerifyFailed();
  await openSqlite();
  Database database = await constructDatabase(logStatements: false);
  await database.netCoreSyncInitialize();
  Global.instance.setDatabase(database);
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
      home: SigninPage(),
    );
  }
}
