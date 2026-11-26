
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewBillList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Map<int, int> quantities;
  final Map<int, TextEditingController> controllers;
  final Function(int) onIncrease;
  final Function(int) onDecrease;
  final Function(int, int) onQuantityChanged;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const NewBillList({
    super.key,
    required this.items,
    required this.quantities,
    required this.controllers,
    required this.onIncrease,
    required this.onDecrease,
    required this.onQuantityChanged,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: searchController,
          onChanged: (_) => onSearchChanged(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search by items here...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: searchController.clear,
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
        ),

        const SizedBox(height: 15),

        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final int id = item['Item_Menu_Id'];
              final int quantity = quantities[id] ?? 0;

              final controller = controllers.putIfAbsent(
                id,
                () => TextEditingController(
                  text: quantities[id]?.toString() ?? '',
                ),
              );

              return Card(
                color: Colors.white,
                elevation: 3,
                child: ListTile(
                  title: Text(item['Item_Name']),
                  subtitle: Text('₹${item['Price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: quantity > 0
                            ? () => onDecrease(id)
                            : null,
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.indigo,
                        ),
                      ),

                      SizedBox(
                        width: 45,
                        height: 40,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            onQuantityChanged(
                              id,
                              int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),

                      IconButton(
                        onPressed: () => onIncrease(id),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
