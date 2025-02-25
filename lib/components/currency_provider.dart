import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _currency = "LKR";

  String get currency => _currency;

  Future<void> loadCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? "LKR";
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    _currency = newCurrency;
    notifyListeners();
  }
}
