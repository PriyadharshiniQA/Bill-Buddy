
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'payment_summary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int totalBills = 0;
  double totalAmount = 0;

  List<Map<String, dynamic>> paymentSummary = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final billData =
        await DatabaseTable.instance.getTodayDashboardSummary();

    final paymentData =
        await DatabaseTable.instance.getTodayPaymentSummary();

    if (!mounted) return;

    setState(() {
      totalBills = billData['TotalBills'] as int;
      totalAmount =
          (billData['TotalAmount'] as num).toDouble();

      paymentSummary = paymentData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: RefreshIndicator(
        onRefresh: loadDashboard,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Overview',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                DateFormat('dd-MM-yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: summaryCard(
                      'Total Bills',
                      totalBills.toString(),
                      Icons.receipt_long,
                      Colors.indigo,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: summaryCard(
                      'Total Amount',
                      '₹${totalAmount.toStringAsFixed(2)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Payment Summary Separate File
              PaymentSummary(
                paymentSummary: paymentSummary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 5),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
