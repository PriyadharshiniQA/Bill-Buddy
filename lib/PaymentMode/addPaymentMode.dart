

import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPaymentModePage extends StatefulWidget {
  const AddPaymentModePage({super.key});

  @override
  State<AddPaymentModePage> createState() =>
      _AddPaymentModePageState();
}

class _AddPaymentModePageState extends State<AddPaymentModePage> {

  // 1. Form Key
  final _formKey = GlobalKey<FormState>();

  // 2. Focus Nodes
  final FocusNode addPaymentModeFocus = FocusNode();
  final FocusNode billPrefixFocus = FocusNode();

  // 3. Text Controllers
  final TextEditingController addPaymentModeController =
      TextEditingController();

  final TextEditingController billPrefixController =
      TextEditingController();

  // 4. Dispose Controllers and Focus Nodes
  @override
  void dispose() {
    addPaymentModeController.dispose();
    billPrefixController.dispose();

    addPaymentModeFocus.dispose();
    billPrefixFocus.dispose();

    super.dispose();
  }

  // 5. Main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: _appBar(),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // Payment Mode Name
              _paymentNameField(),

              const SizedBox(height: 15),

              // Bill Prefix
              _billPrefixField(),

              const SizedBox(height: 15),

              // Add Button
              _addPaymentModeButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 6. AppBar
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      title: Text(
        'Add Payment Mode',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 7. Payment Mode Name Field
  Widget _paymentNameField() {
    return TextFormField(
      focusNode: addPaymentModeFocus,
      controller: addPaymentModeController,

      textInputAction: TextInputAction.next,

      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(billPrefixFocus);
      },

      decoration: const InputDecoration(
        labelText: 'Payment Mode Name',
        hintText: 'Enter payment mode name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment, size: 20),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter payment name';
        }

        return null;
      },
    );
  }

  // 8. Bill Prefix Field
  Widget _billPrefixField() {
    return TextFormField(
      focusNode: billPrefixFocus,
      controller: billPrefixController,

      textInputAction: TextInputAction.done,

      onFieldSubmitted: (value) {
        _validateAndSave();
      },

      decoration: const InputDecoration(
        labelText: 'Bill Prefix Code',
        hintText: 'Enter bill prefix code',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt, size: 20),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter bill prefix code';
        }

        return null;
      },
    );
  }

  // 9. Add Payment Mode Button
  Widget _addPaymentModeButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: _validateAndSave,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),

        child: const Text('Add Payment'),
      ),
    );
  }

  // 10. Validate Form and Save
  Future<void> _validateAndSave() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _savePaymentModeSQLite();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 11. Check Duplicate Payment Mode
  Future<bool> _isPaymentModeExists(
    String paymentModeName,
  ) async {

    final db = await DatabaseTable.instance.database;

    final result = await db.query(
      'Mode_of_Bill',

      where: 'LOWER(Bill_Mode_Name) = LOWER(?)',

      whereArgs: [paymentModeName.trim()],
    );

    return result.isNotEmpty;
  }

  // 12. Save Payment Mode into SQLite
  Future<void> _savePaymentModeSQLite() async {

    final String paymentModeName =
        addPaymentModeController.text.trim();

    final String billPrefixCode =
        billPrefixController.text.trim();

    // Check duplicate payment mode
    final bool exists =
        await _isPaymentModeExists(paymentModeName);

    if (!mounted) return;

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment mode already exists'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // Get Database
    final db = await DatabaseTable.instance.database;

    // Insert Payment Mode
    await db.insert(
      'Mode_of_Bill',
      {
        'Bill_Mode_Name': paymentModeName,
        'Bill_Prefix': billPrefixCode,
        'Is_Active': 1,
      },
    );

    if (!mounted) return;

    // Success Message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,

        content: Text(
          'Payment Mode Added Successfully',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Navigate Back and Refresh List
    Navigator.pop(context, true);
  }
}
