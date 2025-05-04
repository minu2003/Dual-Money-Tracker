import 'package:flutter/material.dart';

class AccountSwitcher extends StatefulWidget {
  final Function(String) onAccountChanged;
  final String initialValue;

  const AccountSwitcher({
    Key? key,
    required this.onAccountChanged,
    this.initialValue = 'Personal',
  }) : super(key: key);

  @override
  State<AccountSwitcher> createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 3, top: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        underline: const SizedBox(),
        dropdownColor: Colors.yellow,
        borderRadius: BorderRadius.circular(12),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedValue = newValue;
            });
            widget.onAccountChanged(newValue);
          }
        },
        items: ['Personal', 'Business'].map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
