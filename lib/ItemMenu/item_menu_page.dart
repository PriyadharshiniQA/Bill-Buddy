
import 'package:billbuddy/DatabaseTable/database_table.dart';
import 'package:billbuddy/ItemMenu/add_ItemMenu.dart';
import 'package:billbuddy/ItemMenu/item_menu_list.dart';
import 'package:billbuddy/ItemMenu/item_menu_selection.dart';
import 'package:billbuddy/ItemMenu/item_menu_status.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class ItemMenuListPage extends StatefulWidget {
  const ItemMenuListPage({super.key});

  @override
  State<ItemMenuListPage> createState() =>
      _ItemMenuListPageState();
}

class _ItemMenuListPageState extends State<ItemMenuListPage> {

  // Item List
  List<Map<String, dynamic>> itemList = [];

  // Selected Item IDs
  Set<int> selectedItemIds = {};

  // Search Controller
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();
    getItemMenu();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Get Items from Database
  Future<void> getItemMenu() async {
    final db = await DatabaseTable.instance.database;

    final result = await db.query(
      'Items_Menu',
      orderBy: 'Item_Menu_Id DESC',
    );

    if (!mounted) return;

    setState(() {
      itemList = result;
    });
  }

  // Search Function
  void searchItem(String value) {
    setState(() {
      searchText = value;
    });
  }

  // Select All / Unselect All
  void selectAllItems(bool? value) {
    setState(() {
      if (value == true) {
        selectedItemIds = itemList
            .map((item) => item['Item_Menu_Id'] as int)
            .toSet();
      } else {
        selectedItemIds.clear();
      }
    });
  }

  // Individual Checkbox
  void selectSingleItem(int itemId, bool? value) {
    setState(() {
      if (value == true) {
        selectedItemIds.add(itemId);
      } else {
        selectedItemIds.remove(itemId);
      }
    });
  }

  // Navigate to Add Item Page
  Future<void> navigateToAddMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemMenuPage(),
      ),
    );

    if (result == true) {
      getItemMenu();
    }
  }

  // Add Button
  Widget addButton() {
    return Tooltip(
      message: 'Add Item Menu',
      child: ElevatedButton.icon(
        onPressed: navigateToAddMenu,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  // Update Status Button
  Widget statusButton() {
    return PopupMenuButton<int>(
      enabled: selectedItemIds.isNotEmpty,

      onSelected: (status) async {
        await ItemMenuStatus.updateStatus(
          context: context,
          selectedItemIds: selectedItemIds,
          status: status,
          onSuccess: () {
            setState(() {
              selectedItemIds.clear();
            });

            getItemMenu();
          },
        );
      },

      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 1,
          child: Text('Active'),
        ),
        PopupMenuItem(
          value: 0,
          child: Text('Inactive'),
        ),
      ],

      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: selectedItemIds.isNotEmpty
              ? Colors.indigo
              : Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              'Update Status',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 234, 234, 234),
        title: Text(
          'Item Menu',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),

        child: Column(
          children: [

            // Top Row
            Row(
              children: [
                ItemMenuSelection(
                  itemList: itemList,
                  selectedItemIds: selectedItemIds,
                  onSelectAll: selectAllItems,
                  onItemSelected: selectSingleItem,
                ),

                const Spacer(),

                addButton(),

                const SizedBox(width: 10),

                statusButton(),
              ],
            ),

            const SizedBox(height: 10),

            // List Page
            Expanded(
              child: ItemMenuList(
                itemList: itemList,
                selectedItemIds: selectedItemIds,
                searchController: searchController,
                searchText: searchText,
                onSearch: searchItem,
                onItemSelected: selectSingleItem,
                onRefresh: getItemMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
