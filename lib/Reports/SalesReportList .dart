

import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:billbuddy/Reports/BillDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesReportList extends StatefulWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final String selectedPaymentMode;

  const SalesReportList({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedPaymentMode,
  });

  @override
  State<SalesReportList> createState() => _SalesReportListState();
}

class _SalesReportListState extends State<SalesReportList> {

  // Bill Header List
  List<Map<String, dynamic>> billHeaderList = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getSalesReport();
  }

  // Reload when date or payment mode changes
  @override
  void didUpdateWidget(covariant SalesReportList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fromDate != widget.fromDate ||
        oldWidget.toDate != widget.toDate ||
        oldWidget.selectedPaymentMode != widget.selectedPaymentMode) {
      getSalesReport();
    }
  }

  // Get Sales Report
  Future<void> getSalesReport() async {

    setState(() {
      isLoading = true;
    });

    try {
      final db = await DatabaseTable.instance.database;

      DateTime startDate = DateTime(
        widget.fromDate.year,
        widget.fromDate.month,
        widget.fromDate.day,
      );

      DateTime endDate = DateTime(
        widget.toDate.year,
        widget.toDate.month,
        widget.toDate.day,
      ).add(const Duration(days: 1));

      final result = await db.rawQuery(
        '''
        SELECT
          B.Bill_Id,
          B.Bill_No,
          B.Total_Amount,
          B.Bill_Date,
          B.Bill_Mode_Id,
          M.Bill_Mode_Name,
          M.Bill_Prefix

        FROM Bill_Header B

        INNER JOIN Mode_of_Bill M
        ON B.Bill_Mode_Id = M.Bill_Mode_Id

        WHERE B.Bill_Date >= ?
        AND B.Bill_Date < ?

        ${widget.selectedPaymentMode == 'All' ? '' : 'AND M.Bill_Mode_Name = ?'}

        ORDER BY B.Bill_Date DESC
        ''',

        widget.selectedPaymentMode == 'All'
            ? [
                startDate.toIso8601String(),
                endDate.toIso8601String(),
              ]
            : [
                startDate.toIso8601String(),
                endDate.toIso8601String(),
                widget.selectedPaymentMode,
              ],
      );

      if (!mounted) return;

      setState(() {
        billHeaderList = result;
      });

    } catch (e) {
      debugPrint('Sales Report Error: $e');

    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Sales Report List UI
  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (billHeaderList.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No Bills Found'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: billHeaderList.length,

        itemBuilder: (context, index) {

          final bill = billHeaderList[index];

          final billNo =
              '${bill['Bill_Prefix']}${bill['Bill_Id']}';

          final billDate =
              DateTime.parse(bill['Bill_Date'].toString());

          final totalAmount =
              double.parse(bill['Total_Amount'].toString());

          return Card(
            margin: const EdgeInsets.only(bottom: 10),

            child: ListTile(

              // Bill Number and Amount
              title: Row(
                children: [

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillDetailPage(
                              billId: int.parse(
                                bill['Bill_Id'].toString(),
                              ),
                            ),
                          ),
                        );
                      },

                      child: Text(
                        billNo,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                ],
              ),

              // Date and Payment Mode
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 15,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          '${billDate.day}-${billDate.month}-${billDate.year}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      bill['Bill_Mode_Name'].toString(),
                      style: const TextStyle(fontSize: 13),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
