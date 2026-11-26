

import 'package:billbuddy/DatabaseTable/database_table.dart';

class ReviewBillService {

  // Load active payment modes
  Future<List<Map<String, dynamic>>> getActivePaymentModes() async {
    final db = await DatabaseTable.instance.database;

    return await db.query(
      'Mode_of_Bill',
      where: 'Is_Active = ?',
      whereArgs: [1],
    );
  }

  // Save Bill
  Future<void> saveBill({
    required List<Map<String, dynamic>> selectedItems,
    required double totalAmount,
    required int billNo,
    required int billModeId,
  }) async {

    final db = await DatabaseTable.instance.database;

    await db.transaction((txn) async {

      // Insert Bill Header
      int billId = await txn.insert('Bill_Header', {
        'Bill_No': billNo.toString(),
        'Customer_Name': null,
        'Contact_No': null,
        'Total_Amount': totalAmount,
        'Bill_Date': DateTime.now().toIso8601String(),
        'Bill_Mode_Id': billModeId,
      });

      // Insert Bill Details
      for (var item in selectedItems) {

        int itemId = item['Item_Menu_Id'];
        int quantity = item['Quantity'];

        double price = (item['Price'] as num).toDouble();

        double lineTotal = quantity * price;

        await txn.insert('Bill_Details', {
          'Bill_Id': billId,
          'Item_Menu_Id': itemId,
          'Quantity': quantity,
          'Price': price,
          'GST_Perc': null,
          'Tax_Amount': null,
          'Line_Total': lineTotal,
        });
      }
    });
  }
}
