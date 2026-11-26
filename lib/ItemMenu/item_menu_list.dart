
import 'package:billbuddy/ItemMenu/editItemMenu.dart';
import 'package:billbuddy/ItemMenu/item_menu_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemMenuList extends StatelessWidget {
  final List<Map<String, dynamic>> itemList;
  final Set<int> selectedItemIds;
  final TextEditingController searchController;
  final String searchText;

  final Function(String) onSearch;
  final Function(int, bool?) onItemSelected;
  final VoidCallback onRefresh;

  const ItemMenuList({
    super.key,
    required this.itemList,
    required this.selectedItemIds,
    required this.searchController,
    required this.searchText,
    required this.onSearch,
    required this.onItemSelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = itemList.where((item) {
      return item['Item_Name']
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Search Field
        TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Search Item Name here...',
            filled: true,
            fillColor: const Color.fromARGB(255, 242, 242, 242),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchText.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      searchController.clear();
                      onSearch('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Item List
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(child: Text('No Item Menu found'))
              : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    final itemId = item['Item_Menu_Id'] as int;
                    final isActive = item['Is_Active'] == 1;

                    return Card(
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text('${index + 1}'),
                        ),

                        title: Text(
                          item['Item_Name'].toString(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          'Price: ₹${item['Price']}',
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit Button
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.indigo,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditItemMenuPage(item: item),
                                  ),
                                );

                                if (result == true) {
                                  onRefresh();
                                }
                              },
                            ),

                            // Active / Inactive Icon
                            Icon(
                              isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),

                            // Checkbox
                            ItemMenuCheckbox(
                              itemId: itemId,
                              selectedItemIds: selectedItemIds,
                              onChanged: onItemSelected,
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
