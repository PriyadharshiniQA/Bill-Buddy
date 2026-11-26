
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentSummary extends StatelessWidget {
  final List<Map<String, dynamic>> paymentSummary;

  const PaymentSummary({
    super.key,
    required this.paymentSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: paymentSummary.map((payment) {
            final mode = payment['PaymentMode'].toString();
            final count = payment['BillCount'].toString();
            final amount =
                (payment['TotalAmount'] as num).toDouble();

            final bool isCash = mode.toLowerCase() == 'cash';

            final color =
                isCash ? Colors.orange : Colors.deepPurple;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: summaryCard(
                  '$mode Bills: $count',
                  '₹${amount.toStringAsFixed(2)}',
                  isCash
                      ? Icons.money
                      : Icons.account_balance_wallet,
                  color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 5),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
