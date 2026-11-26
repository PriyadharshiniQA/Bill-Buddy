
import 'package:billbuddy/ReviewBill/quantity_dialog.dart';
import 'package:billbuddy/ReviewBill/review_BillList.dart';
import 'package:billbuddy/ReviewBill/review_BillService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewBillpage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalAmount;
  final int billNo;

  const ReviewBillpage({
    super.key,
    required this.selectedItems,
    required this.totalAmount,
    required this.billNo,
  });

  @override
  State<ReviewBillpage> createState() => _ReviewBillpageState();
}

class _ReviewBillpageState extends State<ReviewBillpage> {

  final ReviewBillService service = ReviewBillService();

  String selectedBillMode = '';

  List<Map<String, dynamic>> activePaymentModes = [];

  // Load active payment modes
  @override
  void initState() {
    super.initState();
    _loadPaymentModes();
  }

  Future<void> _loadPaymentModes() async {
    final result = await service.getActivePaymentModes();

    if (!mounted) return;

    setState(() {
      activePaymentModes = result;

      if (result.isNotEmpty) {
        selectedBillMode =
            result.first['Bill_Mode_Name'].toString();
      }
    });
  }

  // Edit item quantity
  Future<void> editItemQuantity(
    Map<String, dynamic> item,
  ) async {

    final updatedQty = await QuantityDialog.show(
      context: context,
      itemName: item['Item_Name'].toString(),
      price: (item['Price'] as num).toDouble(),
      currentQty: item['Quantity'] as int,
    );

    if (updatedQty == null || !mounted) return;

    setState(() {
      if (updatedQty > 0) {
        item['Quantity'] = updatedQty;
      } else {
        widget.selectedItems.remove(item);
      }
    });
  }

  // Delete item
  void deleteItem(int index) {
    setState(() {
      widget.selectedItems.removeAt(index);
    });
  }

  // Calculate total amount
  double get totalAmount {
    return widget.selectedItems.fold(0.0, (sum, item) {
      return sum +
          (item['Quantity'] as int) *
          (item['Price'] as num).toDouble();
    });
  }

  // Save bill
  Future<void> _saveBill() async {

    // Check selected items
    if (widget.selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check payment mode
    if (selectedBillMode.isEmpty ||
        activePaymentModes.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a Payment Mode'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {

      // Get selected payment mode
      final selectedPayment = activePaymentModes.firstWhere(
        (payment) =>
            payment['Bill_Mode_Name'].toString() ==
            selectedBillMode,
      );

      int billModeId = selectedPayment['Bill_Mode_Id'] as int;

      // Call service to save bill
      await service.saveBill(
        selectedItems: widget.selectedItems,
        totalAmount: totalAmount,
        billNo: widget.billNo,
        billModeId: billModeId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Review Bill',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Bill No: ${widget.billNo}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),

            const SizedBox(height: 3),

            Text(
              'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 71, 71, 71),
                  ),
                ),

                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Item List and Payment Modes
            Expanded(
              child: ReviewBillList(
                selectedItems: widget.selectedItems,
                paymentModes: activePaymentModes,
                selectedBillMode: selectedBillMode,

                onEdit: editItemQuantity,
                onDelete: deleteItem,

                onModeSelected: (mode) {
                  setState(() {
                    selectedBillMode = mode;
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

            // Save Bill Button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: _saveBill,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),

                child: const Text('Save Bill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
