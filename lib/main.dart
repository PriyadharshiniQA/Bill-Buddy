
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:billbuddy/Login/login.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize database
  final db = await DatabaseTable.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, 
    home: LoginPage());
  }
}
