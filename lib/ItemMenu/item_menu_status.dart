

import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:flutter/material.dart';

class ItemMenuStatus {
  static Future<void> updateStatus({
    required BuildContext context,
    required Set<int> selectedItemIds,
    required int status,
    required VoidCallback onSuccess,
  }) async {
    try {
      if (selectedItemIds.isEmpty) return;

      final db = await DatabaseTable.instance.database;

      final ids = selectedItemIds.toList();

      await db.update(
        'Items_Menu',
        {'Is_Active': status},
        where: 'Item_Menu_Id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );

      onSuccess();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 1
                ? 'Items activated successfully'
                : 'Items deactivated successfully',
          ),
          backgroundColor:
              status == 1 ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
