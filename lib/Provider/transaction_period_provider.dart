import 'package:flutter/material.dart';

enum TransactionPeriod { day, month, year }

class TransactionPeriodProvider with ChangeNotifier {
  TransactionPeriod _selectedPeriod = TransactionPeriod.month;
  DateTime? _selectedDate;

  TransactionPeriod get selectedPeriod => _selectedPeriod;
  DateTime? get selectedDate => _selectedDate;

  void setPeriod(TransactionPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
