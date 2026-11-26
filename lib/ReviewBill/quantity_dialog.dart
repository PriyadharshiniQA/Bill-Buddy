import 'package:flutter/material.dart';
class QuantityDialog {
  //Separate Dialog function
  static Future<int?> show({
    required BuildContext context,
    required String itemName,
    required double price,
    required int currentQty,

  })async{
    //Controller for editable qty
    TextEditingController qtyController = TextEditingController(text: currentQty.toString());
    int tempQty = currentQty;
    String? errorMessage;

    // Open dialog and receive result
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {

        return StatefulBuilder(
          builder: (context, dialogSetState) {

            return AlertDialog(
              backgroundColor: const Color(0xFFF4F0F8),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              contentPadding: const EdgeInsets.all(16),

              content: SizedBox(
                width: 270,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Item Name
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // MRP
                    Text(
                      'MRP ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Current Quantity
                    Text(
                      'Current Qty: $currentQty',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quantity controls
                    Row(
                      children: [

                        // Minus Button
                        IconButton(
                          onPressed: () {
                            dialogSetState(() {

                              if (tempQty > 1) {
                                tempQty--;
                              }

                              qtyController.text =
                                  tempQty.toString();

                              errorMessage = null;
                            });
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.indigo,
                          ),
                        ),

                        // Editable Quantity
                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,

                            decoration: InputDecoration(
                              labelText: 'Qty',
                              errorText: errorMessage,
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 1.5,
                                ),
                              ),
                            ),

                            onChanged: (value) {
                              dialogSetState(() {
                                tempQty =
                                    int.tryParse(value) ?? 0;
                                errorMessage = null;
                              });
                            },
                          ),
                        ),

                        // Plus Button
                        IconButton(
                          onPressed: () {
                            dialogSetState(() {

                              tempQty++;

                              qtyController.text =
                                  tempQty.toString();

                              errorMessage = null;
                            });
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cancel and OK
              actions: [

                // Cancel
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                // OK
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {

                    int? enteredQty =
                        int.tryParse(qtyController.text);

                    if (enteredQty == null || enteredQty < 1) {
                      dialogSetState(() {
                        errorMessage =
                            'Enter quantity greater than 0';
                      });
                      return;
                    }

                    // Return updated quantity
                    Navigator.pop(
                      dialogContext,
                      enteredQty,
                    );
                  },

                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    // Dispose controller
    qtyController.dispose();

    return result;
  }
}