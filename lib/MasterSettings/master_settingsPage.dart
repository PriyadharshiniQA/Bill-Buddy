
import 'package:billbuddy/ItemMenu/item_menu_page.dart';
import 'package:billbuddy/PaymentMode/paymentModeList.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MasterSettingsPage extends StatefulWidget {
  const new({super.key});

  @override
  State<MasterSettingsPage> createState() => _MasterSettingsPageState();
}

class _MasterSettingsPageState extends State<MasterSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),

        title: Text(
          'Master Settings',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Item menu tile
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color.fromARGB(255, 237, 237, 237),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.indigo,
                    size: 25,
                  ),
                ),

                title: const Text('Item Menu Settings'),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemMenuListPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            //Payment Mode Tile
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color.fromARGB(255, 237, 237, 237),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.indigo,
                    size: 25,
                  ),
                ),
                title: const Text('Payment Mode Settings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>const PaymentModelList()));},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
