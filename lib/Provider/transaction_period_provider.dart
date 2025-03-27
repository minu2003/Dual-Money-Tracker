import 'package:flutter/material.dart';

class TransactionPeriodProvider with ChangeNotifier {
  DateTime? _selectedDate;
  DateTime? _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedYear;

  DateTime? get selectedDate => _selectedDate;
  DateTime? get selectedMonth => _selectedMonth;
  DateTime? get selectedYear => _selectedYear;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedMonth(DateTime? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setSelectedYear(DateTime? year) {
    _selectedYear = year;
    notifyListeners();
  }
}
