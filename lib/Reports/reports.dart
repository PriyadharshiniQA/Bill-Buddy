
import 'package:billbuddy/Reports/SalesReportPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class reportsPage extends StatefulWidget {
  const reportsPage({super.key});

  @override
  State<reportsPage> createState() => _reportsPageState();
}

class _reportsPageState extends State<reportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),

        title: Text(
          'Reports',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromARGB(255, 237, 237, 237),
            child: const Icon(
              Icons.bar_chart,
              color: Colors.indigo,
              size: 25,
            ),
          ),
          title: const Text('Sales Report'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalesReportPage()),
            );
          },
        ),
      ),
    );
  }
}
