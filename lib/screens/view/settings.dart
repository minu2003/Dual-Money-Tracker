import 'package:flutter/material.dart';
import 'package:money_app/screens/view/forgot_password_screen.dart';
import 'package:money_app/screens/view/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Provider/firestore_services.dart';
import '../../Provider/transaction_period_provider.dart';
import 'package:money_app/theme/theme_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _dailyNotification = false;
  bool _monthlyNotification = false;
  bool _yearlyNotification = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyNotification = prefs.getBool('dailyNotification') ?? false;
      _monthlyNotification = prefs.getBool('monthlyNotification') ?? false;
      _yearlyNotification = prefs.getBool('yearlyNotification') ?? false;
    });
  }

  Future<void> _saveNotificationPrefs(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _sendNotification(String period) async {
    final transactionPeriodProvider =
    Provider.of<TransactionPeriodProvider>(context, listen: false);

    DateTime? selectedDate = transactionPeriodProvider.selectedDate;
    DateTime? selectedMonth = transactionPeriodProvider.selectedMonth;
    DateTime? selectedYear = transactionPeriodProvider.selectedYear;

    String paymentMethod = 'Cash';

    try {
      final snapshot = await _firestoreService
          .getTransactions(paymentMethod, selectedDate, selectedMonth, selectedYear)
          .first;

      double totalIncome = 0.0;
      double totalExpense = 0.0;
      double totalCredit = 0.0;
      double totalDebit = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double amount = (data['amount'] ?? 0.0).toDouble();

        if (data['type'] == 'income') {
          totalIncome += amount;
        } else if (data['type'] == 'expense') {
          totalExpense += amount;
        } else if (data['type'] == 'credit') {
          totalCredit += amount;
        } else if (data['type'] == 'debit') {
          totalDebit += amount;
        }
      }

      String personalSummary = 'Income: LKR ${totalIncome.toStringAsFixed(2)}\n'
          'Expense: LKR ${totalExpense.toStringAsFixed(2)}';
      String businessSummary = 'Credit: LKR ${totalCredit.toStringAsFixed(2)}\n'
          'Debit: LKR ${totalDebit.toStringAsFixed(2)}';

      String personalHighlight = totalIncome > totalExpense ? 'Income' : 'Expense';
      String businessHighlight = totalCredit > totalDebit ? 'Credit' : 'Debit';

      String notificationMessage = '''
[$period Notification]
--- Personal ---
$personalSummary
Higher: $personalHighlight

--- Business ---
$businessSummary
Higher: $businessHighlight
''';

      print(notificationMessage);

    } catch (e) {
      print('Failed to fetch $period summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontSize: 25)),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Profile"),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => edit_profile()));
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Change Password"),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.format_paint),
                    title: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Theme"),
                    ),
                    onTap: () {
                      theme_provider(context);
                    },
                  ),
                  const Divider(height: 70),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 30),
                  SwitchListTile(
                    title: const Text("Daily Notification"),
                    value: _dailyNotification,
                    activeTrackColor: Colors.blue.shade200,
                    onChanged: (val) {
                      setState(() {
                        _dailyNotification = val;
                      });
                      _saveNotificationPrefs('dailyNotification', val);
                      if (val) _sendNotification('Daily');
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Monthly Notification"),
                    value: _monthlyNotification,
                    activeTrackColor: Colors.blue.shade200,
                    onChanged: (val) {
                      setState(() {
                        _monthlyNotification = val;
                      });
                      _saveNotificationPrefs('monthlyNotification', val);
                      if (val) _sendNotification('Monthly');
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Yearly Notification"),
                    value: _yearlyNotification,
                    activeTrackColor: Colors.blue.shade200,
                    onChanged: (val) {
                      setState(() {
                        _yearlyNotification = val;
                      });
                      _saveNotificationPrefs('yearlyNotification', val);
                      if (val) _sendNotification('Yearly');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
