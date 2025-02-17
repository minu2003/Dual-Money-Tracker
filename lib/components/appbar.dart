import 'package:flutter/material.dart';
import 'AccountSwitcher.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onAccountChanged;

  const CustomAppBar({Key? key, required this.onAccountChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFECECEC),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          Image.asset(
            "assets/Logo.png",
            height: 50,
          ),
        ],
      ),
      actions: [
        AccountSwitcher(onAccountChanged: onAccountChanged),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
