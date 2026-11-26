
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillDetailPage extends StatefulWidget {

  final int billId;

  const BillDetailPage({
    super.key,
    required this.billId,
  });

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {

  // =====================================================
  // VARIABLES
  // =====================================================

  bool isLoading = true;

  Map<String, dynamic>? billHeader;

  List<Map<String, dynamic>> billItems = [];


  // =====================================================
  // DATABASE - GET BILL DETAILS
  // =====================================================

  Future<void> getBillDetails() async {

    try {

      final db = await DatabaseTable.instance.database;

      // Get Bill Header and Payment Mode
      final headerResult = await db.rawQuery(
        '''
        SELECT
          B.Bill_Id,
          B.Bill_No,
          B.Total_Amount,
          B.Bill_Date,
          M.Bill_Mode_Name,
          M.Bill_Prefix

        FROM Bill_Header B

        INNER JOIN Mode_of_Bill M
        ON B.Bill_Mode_Id = M.Bill_Mode_Id

        WHERE B.Bill_Id = ?
        ''',
        [widget.billId],
      );

      // Get Bill Items
      final itemResult = await db.rawQuery(
        '''
        SELECT
          I.Item_Name,
          D.Quantity,
          D.Price,
          D.Line_Total

        FROM Bill_Details D

        INNER JOIN Items_Menu I
        ON D.Item_Menu_Id = I.Item_Menu_Id

        WHERE D.Bill_Id = ?

        ORDER BY D.Bill_Detail_Id
        ''',
        [widget.billId],
      );

      if (!mounted) return;

      setState(() {

        billHeader = headerResult.isNotEmpty
            ? headerResult.first
            : null;

        billItems = itemResult;

        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bill details: $e'),
        ),
      );
    }
  }


  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    getBillDetails();
  }


  // =====================================================
  // MAIN BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,

        title: Text(
          'Bill Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading

          // Loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            )

          // Bill Not Found
          : billHeader == null
              ? const Center(
                  child: Text('Bill Not Found'),
                )

              // Bill Details
              : billDetailsBody(),
    );
  }


  // =====================================================
  // BILL DETAILS BODY
  // =====================================================

  Widget billDetailsBody() {

    final bill = billHeader!;

    final billDate =
        DateTime.parse(bill['Bill_Date'].toString());

    final totalAmount =
        double.parse(bill['Total_Amount'].toString());

    // Generate Bill Number
    final billNo =
        '${bill['Bill_Prefix']}${bill['Bill_Id']}';

    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        // -----------------------------------------------
        // BILL HEADER CARD
        // -----------------------------------------------

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  'Bill No: $billNo',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),

                const Divider(height: 25),

                // Bill Date
                billInfoRow(
                  'Bill Date',
                  '${billDate.day}-${billDate.month}-${billDate.year}',
                ),

                const SizedBox(height: 12),

                // Payment Mode
                billInfoRow(
                  'Payment Mode',
                  bill['Bill_Mode_Name'].toString(),
                ),

                const SizedBox(height: 12),

                // Total Amount
                billInfoRow(
                  'Total Amount',
                  '₹${totalAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),


        // -----------------------------------------------
        // ITEM DETAILS HEADING
        // -----------------------------------------------

        Text(
          'Item Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),


        // -----------------------------------------------
        // NO ITEMS FOUND
        // -----------------------------------------------

        if (billItems.isEmpty)
          const Center(
            child: Text('No Items Found'),
          ),


        // -----------------------------------------------
        // BILL ITEMS LIST
        // -----------------------------------------------

        ...billItems.map((item) {

          final quantity =
              int.parse(item['Quantity'].toString());

          final price =
              double.parse(item['Price'].toString());

          final lineTotal =
              double.parse(item['Line_Total'].toString());

          return Card(
            margin: const EdgeInsets.only(bottom: 10),

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // Item Name
                  Text(
                    item['Item_Name'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Divider(),

                  // Quantity
                  billInfoRow(
                    'Quantity',
                    quantity.toString(),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  billInfoRow(
                    'Price',
                    '₹${price.toStringAsFixed(2)}',
                  ),

                  const SizedBox(height: 8),

                  // Line Total
                  billInfoRow(
                    'Line Total',
                    '₹${lineTotal.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }


  // =====================================================
  // COMMON ROW WIDGET
  // =====================================================

  Widget billInfoRow(String label, String value) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),

        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
