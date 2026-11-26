
import 'package:flutter/material.dart';

class ReviewBillList extends StatelessWidget {
  final List<Map<String, dynamic>> selectedItems;
  final List<Map<String, dynamic>> paymentModes;

  final String selectedBillMode;

  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;
  final Function(String) onModeSelected;

  const ReviewBillList({
    super.key,
    required this.selectedItems,
    required this.paymentModes,
    required this.selectedBillMode,
    required this.onEdit,
    required this.onDelete,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Selected item list
        Expanded(
          child: ListView.builder(
            itemCount: selectedItems.length,
            itemBuilder: (context, index) {

              final item = selectedItems[index];

              String itemName = item['Item_Name'].toString();
              int quantity = item['Quantity'];
              double price = (item['Price'] as num).toDouble();

              double lineTotal = quantity * price;

              return Card(
                elevation: 2,
                color: Colors.white,
                child: ListTile(

                  // Edit quantity
                  onTap: () => onEdit(item),

                  title: Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '$quantity × ₹${price.toStringAsFixed(2)}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Line total
                      Text(
                        '₹${lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Delete item
                      IconButton(
                        onPressed: () => onDelete(index),
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Payment Mode
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Payment Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: paymentModes.map((payment) {

                String mode =
                    payment['Bill_Mode_Name'].toString();

                bool isSelected = selectedBillMode == mode;

                return GestureDetector(
                  onTap: () => onModeSelected(mode),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.indigo
                          : Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(
                        color: Colors.indigo,
                      ),
                    ),

                    child: Text(
                      mode,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
