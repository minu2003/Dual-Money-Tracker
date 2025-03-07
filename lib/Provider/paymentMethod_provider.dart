import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodProvider with ChangeNotifier {
  late String _selectedMethod;

  String get selectedMethod => _selectedMethod;

  PaymentMethodProvider() {
    _loadPaymentMethod();
  }

  Future<void> _loadPaymentMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedMethod = prefs.getString('paymentMethod') ?? "Cash";
    notifyListeners();
  }

  Future<void> setPaymentMethod(String newMethod) async {
    if (_selectedMethod != newMethod) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('paymentMethod', newMethod);
      _selectedMethod = newMethod;
      notifyListeners();
    }
  }
}
