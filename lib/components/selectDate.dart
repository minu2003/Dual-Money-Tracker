import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/transaction_period_provider.dart';

class DateProvider {
  static ValueNotifier<String> dateNotifier = ValueNotifier<String>("Select Period");

  static void showDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Select Time Period", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSelectionTile(context, "Day", Icons.today, TransactionPeriod.day),
              _buildSelectionTile(context, "Month", Icons.calendar_view_month, TransactionPeriod.month),
              _buildSelectionTile(context, "Year", Icons.event, TransactionPeriod.year),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSelectionTile(BuildContext context, String title, IconData icon, TransactionPeriod period) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        dateNotifier.value = title;
        Provider.of<TransactionPeriodProvider>(context, listen: false).setPeriod(period);
        Navigator.pop(context);
      },
    );
  }
}
