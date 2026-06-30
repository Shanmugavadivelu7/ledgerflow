import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'PAID';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid ? Colors.green.shade200 : Colors.amber.shade300,
        ),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Credit',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isPaid ? Colors.green.shade700 : Colors.amber.shade800,
        ),
      ),
    );
  }
}
