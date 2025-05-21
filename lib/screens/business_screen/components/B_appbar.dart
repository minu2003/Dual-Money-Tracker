import 'package:flutter/material.dart';
import '../../../components/AccountSwitcher.dart';

class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onAccountChanged;
  final String currentAccount;

  const customAppBar({Key? key, required this.onAccountChanged, required this.currentAccount,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: 10),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/dualLogoBusiness.png",
              height: 50,
            ),
          ],
        ),
        actions: [
          AccountSwitcher(onAccountChanged: onAccountChanged, initialValue: currentAccount,),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
