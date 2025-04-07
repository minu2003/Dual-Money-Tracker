import 'package:flutter/material.dart';
import 'package:money_app/screens/business_screen/business_home_screen.dart';
import 'package:money_app/screens/view/home_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  String currentAccount = 'Personal';

  void handleAccountSwitch(String newAccount) {
    setState(() {
      currentAccount = newAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentAccount == 'Business') {
      return BusinessHomeScreen(onAccountChanged: handleAccountSwitch);
    } else {
      return HomeScreen(onAccountChanged: handleAccountSwitch);
    }
  }
}
