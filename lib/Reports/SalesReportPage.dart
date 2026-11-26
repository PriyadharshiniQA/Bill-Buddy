

import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:billbuddy/Reports/SalesReportList%20.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {

  // Variables
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String selectedPaymentMode = 'All';

  List<String> paymentModes = ['All'];

  // Load Payment Modes
  Future<void> getPaymentModes() async {

    final db = await DatabaseTable.instance.database;

    final result = await db.query(
      'Mode_of_Bill',
      columns: ['Bill_Mode_Name'],
      where: 'Is_Active = ?',
      whereArgs: [1],
    );

    if (!mounted) return;

    setState(() {
      paymentModes = [
        'All',
        ...result.map(
          (item) => item['Bill_Mode_Name'].toString(),
        ),
      ];
    });
  }

  // From Date
  Future<void> selectedFromDate() async {

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        fromDate = pickedDate;

        if (toDate.isBefore(fromDate)) {
          toDate = fromDate;
        }
      });
    }
  }

  // To Date
  Future<void> selectToDate() async {

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: toDate.isBefore(fromDate) ? fromDate : toDate,
      firstDate: fromDate,
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        toDate = pickedDate;
      });
    }
  }

  // Date Picker Field
  Widget datePickerField({
    required String label,
    required DateTime selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_month),
        ),
        child: Text(
          '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
        ),
      ),
    );
  }

  // Payment Mode Dropdown
  Widget paymentModeDropdown() {

    return DropdownButtonFormField<String>(
      value: selectedPaymentMode,

      decoration: const InputDecoration(
        labelText: 'Payment Mode',
        border: OutlineInputBorder(),
      ),

      items: paymentModes.map((mode) {
        return DropdownMenuItem<String>(
          value: mode,
          child: Text(mode),
        );
      }).toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedPaymentMode = value;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPaymentModes();
  }

  // Main UI
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),

        title: Text(
          'Sales Report',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // From Date and To Date
            Row(
              children: [

                Expanded(
                  child: datePickerField(
                    label: 'From Date',
                    selectedDate: fromDate,
                    onTap: selectedFromDate,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: datePickerField(
                    label: 'To Date',
                    selectedDate: toDate,
                    onTap: selectToDate,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 15),

            // Payment Mode
            paymentModeDropdown(),

            const SizedBox(height: 15),

            // Sales Report List
            SalesReportList(
              fromDate: fromDate,
              toDate: toDate,
              selectedPaymentMode: selectedPaymentMode,
            ),

          ],
        ),
      ),
    );
  }
}
