import 'package:flutter/material.dart';

enum TransactionPeriod { day, month, year }

class TransactionPeriodProvider with ChangeNotifier {
  TransactionPeriod _selectedPeriod = TransactionPeriod.month;

  TransactionPeriod get selectedPeriod => _selectedPeriod;

  void setPeriod(TransactionPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
