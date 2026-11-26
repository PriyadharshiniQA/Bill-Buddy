
import 'package:flutter/material.dart';

class ItemMenuSelection extends StatelessWidget {
  final List<Map<String, dynamic>> itemList;
  final Set<int> selectedItemIds;
  final Function(bool?) onSelectAll;
  final Function(int, bool?) onItemSelected;

  const ItemMenuSelection({
    super.key,
    required this.itemList,
    required this.selectedItemIds,
    required this.onSelectAll,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: itemList.isNotEmpty &&
              itemList.every((item) =>
                  selectedItemIds.contains(
                    item['Item_Menu_Id'] as int,
                  )),
          onChanged: itemList.isEmpty ? null : onSelectAll,
        ),
        const Text('Select All'),
      ],
    );
  }
}

// Individual item checkbox
class ItemMenuCheckbox extends StatelessWidget {
  final int itemId;
  final Set<int> selectedItemIds;
  final Function(int, bool?) onChanged;

  const ItemMenuCheckbox({
    super.key,
    required this.itemId,
    required this.selectedItemIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: selectedItemIds.contains(itemId),
      onChanged: (value) {
        onChanged(itemId, value);
      },
    );
  }
}
