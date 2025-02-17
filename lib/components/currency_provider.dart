import 'package:flutter/material.dart';


final ValueNotifier<String> currencyNotifier = ValueNotifier<String>("LKR");

void currencyProvider(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Currency"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption(context, "LKR"),
            _buildCurrencyOption(context, "USD"),
            _buildCurrencyOption(context, "GBP"),
          ],
        ),
      );
    },
  );
}

ListTile _buildCurrencyOption(BuildContext context, String currency) {
  return ListTile(
    title: Text(currency),
    onTap: () {
      currencyNotifier.value = currency;
      Navigator.of(context).pop();
    },
  );
}
