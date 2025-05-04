import 'package:flutter/material.dart';
import 'AccountSwitcher.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onAccountChanged;
  final String currentAccount;

  const CustomAppBar({
    Key? key,
    required this.onAccountChanged,
    required this.currentAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          Image.asset(
            "assets/dualLogo.png",
            height: 50,
          ),
        ],
      ),
      actions: [
        AccountSwitcher(
          onAccountChanged: onAccountChanged,
          initialValue: currentAccount,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
