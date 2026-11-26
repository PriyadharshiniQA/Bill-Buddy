
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:billbuddy/PaymentMode/addPaymentMode.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentModelList extends StatefulWidget {
  const PaymentModelList({super.key});

  @override
  State<PaymentModelList> createState() =>
      _PaymentModelListState();
}

class _PaymentModelListState extends State<PaymentModelList> {

  List<Map<String, dynamic>> paymentList = [];

  @override
  void initState() {
    super.initState();
    getPaymentMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),
        title: Text(
          'Payment Mode',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),

        child: Column(
          children: [
            _addPaymentButton(),

            const SizedBox(height: 10),

            Expanded(
              child: _paymentModeListView(),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to Add Payment Mode Page
  Future<void> _navigateToAddPaymentMode() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPaymentModePage(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      getPaymentMode();
    }
  }

  // Add Payment Button
  Widget _addPaymentButton() {
    return Align(
      alignment: Alignment.topRight,

      child: ElevatedButton.icon(
        onPressed: _navigateToAddPaymentMode,

        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  // Get Payment Mode Records
  Future<void> getPaymentMode() async {

    final db = await DatabaseTable.instance.database;

    final result = await db.query('Mode_of_Bill');

    if (!mounted) return;

    setState(() {
      paymentList = result;
    });
  }

  // Payment Mode List
  Widget _paymentModeListView() {

    if (paymentList.isEmpty) {
      return const Center(
        child: Text('No Payment Modes Found'),
      );
    }

    return ListView.builder(
      itemCount: paymentList.length,

      itemBuilder: (context, index) {

        final item = paymentList[index];

        final bool isActive = item['Is_Active'] == 1;

        return Card(
          elevation: 3,

          child: ListTile(

            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: Text('${index + 1}'),
            ),

            title: Text(
              item['Bill_Mode_Name'].toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  'Bill Code: ${item['Bill_Prefix']}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),

                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            trailing: Switch(
              value: isActive,
              activeThumbColor: Colors.green,

              onChanged: (value) {
                updatePaymentModeStatus(
                  item['Bill_Mode_Id'] as int,
                  value,
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Update Payment Mode Active / Inactive Status
  Future<void> updatePaymentModeStatus(
    int billModeId,
    bool isActive,
  ) async {

    final db = await DatabaseTable.instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as total '
      'FROM Mode_of_Bill WHERE Is_Active = 1',
    );

    final int activeCount =
        result.first['total'] as int;

    // At least one payment mode must be active
    if (!isActive && activeCount == 1) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least one payment mode must be active.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    await db.update(
      'Mode_of_Bill',
      {'Is_Active': isActive ? 1 : 0},
      where: 'Bill_Mode_Id = ?',
      whereArgs: [billModeId],
    );

    await getPaymentMode();
  }
}
