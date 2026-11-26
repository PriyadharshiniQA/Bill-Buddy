
import 'package:billbuddy/Home/home.dart';
import 'package:billbuddy/MasterSettings/master_settingsPage.dart';
import 'package:billbuddy/Navigation/bottom_navigation.dart';
import 'package:billbuddy/Navigation/logout.dart';
import 'package:billbuddy/NewBill/new_BillPage.dart';
import 'package:billbuddy/Reports/reports.dart';
import 'package:flutter/material.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {

  // Selected Bottom Navigation Index
  int selectedIndex = 0;

  // All Pages
  final List<Widget> pages = [
    HomePage(),
    NewBillpage(),
    reportsPage(),
    MasterSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // AppBar
      appBar: AppBar(
        title: const Text('Bill Buddy'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,

        // Logout
        actions: [
          IconButton(
            onPressed: () {
              Logout.show(context);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      // Body
      body: pages[selectedIndex],

      // Bottom Navigation
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
