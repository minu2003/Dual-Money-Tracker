import 'package:flutter/material.dart';

class AccountSwitcher extends StatefulWidget {
  final Function(String) onAccountChanged;

  const AccountSwitcher({Key? key, required this.onAccountChanged}) : super(key: key);

  @override
  State<AccountSwitcher> createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  List<String> dropdownItems = ['Business', 'Personal'];
  String selectedValue = 'Personal';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 3, top: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF5efce8), Color(0xFF736efe)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
          });
          widget.onAccountChanged(selectedValue);
        },
        items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
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
