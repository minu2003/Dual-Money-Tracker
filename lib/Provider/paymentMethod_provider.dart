import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodProvider with ChangeNotifier {
  String _selectedMethod = "Cash";

  String get selectedMethod => _selectedMethod;

  Future<void> loadPaymentMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedMethod = prefs.getString('paymentMethod') ?? "Cash";
    notifyListeners();
  }

  Future<void> setPaymentMethod(String newMethod) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('paymentMethod', newMethod);
    _selectedMethod = newMethod;
    notifyListeners();
  }
}
