
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditItemMenuPage extends StatefulWidget {

  // Receive selected item details
  final Map<String, dynamic> item;

  const EditItemMenuPage({
    super.key,
    required this.item,
  });

  @override
  State<EditItemMenuPage> createState() =>
      _EditItemMenuPageState();
}

class _EditItemMenuPageState extends State<EditItemMenuPage> {

  // 1. FORM KEY
  final _formKey = GlobalKey<FormState>();

  // 2. TEXT CONTROLLERS
  final TextEditingController itemNameController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  // 3. ACTIVE STATUS
  bool isActive = true;

  // 4. LOAD EXISTING DATABASE VALUES
  @override
  void initState() {
    super.initState();

    itemNameController.text =
        widget.item['Item_Name'].toString();

    priceController.text =
        widget.item['Price'].toString();

    isActive = widget.item['Is_Active'] == 1;
  }

  // 5. DISPOSE CONTROLLERS
  @override
  void dispose() {
    itemNameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // 6. MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Item Menu',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Item Name
              _itemNameField(),

              const SizedBox(height: 15),

              // Price
              _priceField(),

              const SizedBox(height: 15),

              // Active Status
              _activeStatusToggle(),

              const SizedBox(height: 20),

              // Update Button
              _updateButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 7. ITEM NAME FIELD (DISABLED)
  Widget _itemNameField() {
    return TextFormField(
      controller: itemNameController,
      enabled: false,

      decoration: const InputDecoration(
        labelText: 'Item Menu Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.restaurant_menu,
          size: 20,
        ),
      ),
    );
  }

  // 8. PRICE FIELD (EDITABLE)
  Widget _priceField() {
    return TextFormField(
      controller: priceController,

      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),

      decoration: const InputDecoration(
        labelText: 'Price',
        hintText: 'Enter price',
        border: OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.currency_rupee,
          size: 20,
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter price';
        }

        double? price = double.tryParse(value.trim());

        if (price == null) {
          return 'Please enter a valid price';
        }

        if (price <= 0) {
          return 'Price must be greater than 0';
        }

        return null;
      },
    );
  }

  // 9. ACTIVE STATUS TOGGLE
  Widget _activeStatusToggle() {
    return SwitchListTile(
      title: const Text('Is Active'),

      subtitle: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),

      value: isActive,
      activeThumbColor: Colors.indigo,

      onChanged: (value) {
        setState(() {
          isActive = value;
        });
      },
    );
  }

  // 10. UPDATE BUTTON
  Widget _updateButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: updateItemMenu,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),

        child: const Text('Update'),
      ),
    );
  }

  // 11. UPDATE ITEM MENU IN SQLITE
  Future<void> updateItemMenu() async {

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {

      double price =
          double.parse(priceController.text.trim());

      final db = await DatabaseTable.instance.database;

      // Update database record
      await db.update(
        'Items_Menu',

        {
          'Price': price,
          'Is_Active': isActive ? 1 : 0,
        },

        where: 'Item_Menu_Id = ?',

        whereArgs: [
          widget.item['Item_Menu_Id'],
        ],
      );

      if (!mounted) return;

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item Menu Updated Successfully',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to Item Menu List
      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
