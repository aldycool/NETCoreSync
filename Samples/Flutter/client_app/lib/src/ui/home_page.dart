import 'package:flutter/material.dart';
import 'setup_page.dart';
import 'department_list_page.dart';
import 'employee_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: Text("Setup"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetupPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Departments"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DepartmentListPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Employees"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmployeeListPage()),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                child: Text("Sync"),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
