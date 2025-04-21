import 'package:flutter/material.dart';
import '../../../components/AccountSwitcher.dart';

class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onAccountChanged;
  final String currentAccount;

  const customAppBar({Key? key, required this.onAccountChanged, required this.currentAccount,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFECECEC),
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          Image.asset(
            "assets/LogoBusiness.png",
            height: 50,
          ),
        ],
      ),
      actions: [
        AccountSwitcher(onAccountChanged: onAccountChanged, initialValue: currentAccount,),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
