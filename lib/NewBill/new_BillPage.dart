

import 'package:billbuddy/NewBill/new_BillList.dart';
import 'package:billbuddy/NewBill/new_BillService.dart';
import 'package:billbuddy/ReviewBill/review_BillPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewBillpage extends StatefulWidget {
  const NewBillpage({super.key});

  @override
  State<NewBillpage> createState() => _NewBillpageState();
}

class _NewBillpageState extends State<NewBillpage> {
  final NewBillService service = NewBillService();

  int nextBillNo = 1;

  List<Map<String, dynamic>> itemList = [];
  List<Map<String, dynamic>> filteredItemList = [];

  Map<int, int> itemQuantities = {};
  Map<int, TextEditingController> quantityControllers = {};

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _getNextBillNo();
  }

  // Load items
  Future<void> _loadItems() async {
    final items = await service.getActiveItems();

    if (!mounted) return;

    setState(() {
      itemList = items;
      filteredItemList = items;
    });
  }

  // Get next bill number
  Future<void> _getNextBillNo() async {
    final number = await service.getNextBillNo();

    if (!mounted) return;

    setState(() {
      nextBillNo = number;
    });
  }

  // Search items
  void _searchItems() {
    final searchText = searchController.text.toLowerCase();

    setState(() {
      filteredItemList = itemList.where((item) {
        return item['Item_Name']
            .toString()
            .toLowerCase()
            .contains(searchText);
      }).toList();
    });
  }

  // Increase quantity
  void _increaseQuantity(int id) {
    setState(() {
      final quantity = (itemQuantities[id] ?? 0) + 1;
      itemQuantities[id] = quantity;
      quantityControllers[id]!.text = quantity.toString();
    });
  }

  // Decrease quantity
  void _decreaseQuantity(int id) {
    setState(() {
      final quantity = (itemQuantities[id] ?? 0) - 1;

      if (quantity > 0) {
        itemQuantities[id] = quantity;
        quantityControllers[id]!.text = quantity.toString();
      } else {
        itemQuantities.remove(id);
        quantityControllers[id]!.clear();
      }
    });
  }

  // Manual quantity change
  void _quantityChanged(int id, int quantity) {
    setState(() {
      if (quantity > 0) {
        itemQuantities[id] = quantity;
      } else {
        itemQuantities.remove(id);
      }
    });
  }

  // Calculations
  int get totalCombination =>
      service.getTotalCombination(itemQuantities);

  int get totalQuantity =>
      service.getTotalQuantity(itemQuantities);

  double get totalAmount =>
      service.getTotalAmount(itemList, itemQuantities);

  // Navigate to Review Bill
  Future<void> _reviewBill() async {
    List<Map<String, dynamic>> selectedItems = [];

    for (var item in itemList) {
      final id = item['Item_Menu_Id'];
      final quantity = itemQuantities[id] ?? 0;

      if (quantity > 0) {
        selectedItems.add({
          'Item_Menu_Id': id,
          'Item_Name': item['Item_Name'],
          'Price': item['Price'],
          'Quantity': quantity,
        });
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewBillpage(
          selectedItems: selectedItems,
          totalAmount: totalAmount,
          billNo: nextBillNo,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        itemQuantities.clear();

        for (var controller in quantityControllers.values) {
          controller.clear();
        }
      });

      await _getNextBillNo();
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
              'New Bill',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Bill No: $nextBillNo',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: NewBillList(
          items: filteredItemList,
          quantities: itemQuantities,
          controllers: quantityControllers,
          onIncrease: _increaseQuantity,
          onDecrease: _decreaseQuantity,
          onQuantityChanged: _quantityChanged,
          searchController: searchController,
          onSearchChanged: _searchItems,
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combination: $totalCombination',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Quantity: $totalQuantity',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: totalQuantity == 0 ? null : _reviewBill,
                  child: const Text('Review Bill'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    for (var controller in quantityControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }
}
