
import 'package:billbuddy/DatabaseTable/database_table.dart';

class NewBillService {

  Future<List<Map<String, dynamic>>> getActiveItems() async {
    final items = await DatabaseTable.instance.getItemsMenu();

    return items.where((item) => item['Is_Active'] == 1).toList();
  }

  Future<int> getNextBillNo() async {
    final db = await DatabaseTable.instance.database;

    final result = await db.rawQuery(
      'SELECT COALESCE(MAX(Bill_Id), 0) + 1 AS NextId FROM Bill_Header',
    );

    return result.first['NextId'] as int;
  }

  int getTotalCombination(Map<int, int> quantities) {
    return quantities.values.where((q) => q > 0).length;
  }

  int getTotalQuantity(Map<int, int> quantities) {
    return quantities.values.fold(0, (sum, q) => sum + q);
  }

  double getTotalAmount(
    List<Map<String, dynamic>> items,
    Map<int, int> quantities,
  ) {
    double total = 0;

    for (var item in items) {
      int id = item['Item_Menu_Id'];
      int quantity = quantities[id] ?? 0;
      double price = (item['Price'] as num).toDouble();

      total += price * quantity;
    }

    return total;
  }
}