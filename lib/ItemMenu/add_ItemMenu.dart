
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddItemMenuPage extends StatefulWidget {
  const AddItemMenuPage({super.key});

  @override
  State<AddItemMenuPage> createState() => _AddItemMenuPageState();
}

class _AddItemMenuPageState extends State<AddItemMenuPage> {

  // 1. FORM KEY
  final _formKey = GlobalKey<FormState>();

  // 2. TEXT CONTROLLERS
  final TextEditingController itemNameController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  // 3. FOCUS NODES
  final FocusNode itemNameFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();

  // 4. ACTIVE STATUS
  bool isActive = true;

  // 5. DISPOSE CONTROLLERS AND FOCUS NODES
  @override
  void dispose() {
    itemNameController.dispose();
    priceController.dispose();
    itemNameFocus.dispose();
    priceFocus.dispose();
    super.dispose();
  }

  // 6. MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Item Menu',
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

              // Add Button
              _addMenuButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 7. ITEM NAME FIELD
  Widget _itemNameField() {
    return TextFormField(
      controller: itemNameController,
      focusNode: itemNameFocus,
      textInputAction: TextInputAction.next,

      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(priceFocus);
      },

      decoration: const InputDecoration(
        labelText: 'Item Menu Name',
        hintText: 'Enter item name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.restaurant_menu, size: 20),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter item name';
        }
        return null;
      },
    );
  }

  // 8. PRICE FIELD
  Widget _priceField() {
    return TextFormField(
      controller: priceController,
      focusNode: priceFocus,
      textInputAction: TextInputAction.done,

      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),

      onFieldSubmitted: (value) {
        _saveItemMenuSQLite();
      },

      decoration: const InputDecoration(
        labelText: 'Price',
        hintText: 'Enter price',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.currency_rupee, size: 20),
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

  // 10. ADD MENU BUTTON
  Widget _addMenuButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: _saveItemMenuSQLite,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),

        child: const Text('Add Menu'),
      ),
    );
  }

  // 11. CHECK DUPLICATE ITEM NAME
  Future<bool> _isItemMenuExists(String itemName) async {
    final db = await DatabaseTable.instance.database;

    final result = await db.query(
      'Items_Menu',
      where: 'LOWER(Item_Name) = LOWER(?)',
      whereArgs: [itemName.trim()],
    );

    return result.isNotEmpty;
  }

  // 12. INSERT ITEM MENU INTO SQLITE
  Future<void> _saveItemMenuSQLite() async {

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String itemName = itemNameController.text.trim();
    double price = double.parse(priceController.text.trim());

    try {
      final db = await DatabaseTable.instance.database;

      // Check duplicate
      bool exists = await _isItemMenuExists(itemName);

      if (exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item Menu already exists'),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // Insert record
      await db.insert('Items_Menu', {
        'Item_Name': itemName,
        'Price': price,
        'Is_Active': isActive ? 1 : 0,
      });

      if (!mounted) return;

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item Menu Added Successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context, true);

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
}
