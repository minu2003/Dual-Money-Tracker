import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:money_app/Authentication/sign_in.dart';
import 'package:money_app/screens/view/home_screen.dart';
import 'package:money_app/screens/view/settings.dart' as settings_screen;

import '../../../Provider/paymentMethod_provider.dart';
import '../../../Provider/transaction_period_provider.dart';
import '../../../components/currency_provider.dart';

class B_DrawerScreen extends StatefulWidget {
  final Function(String)? onPaymentMethodChanged;
  const B_DrawerScreen({super.key, this.onPaymentMethodChanged});

  @override
  State<B_DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<B_DrawerScreen> {
  DateTime? selectedDate;
  DateTime? selectedMonth;
  DateTime? selectedYear;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedDate(picked);
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedMonth ?? now,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime(2100, 12),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        selectedYear = DateTime(picked.year);
        selectedDate = null;
      });

      Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedDate(null);
      Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedMonth(picked);
      Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedYear(DateTime(picked.year));
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    DateTime now = DateTime.now();
    int? selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            height: 200,
            width: 100,
            child: ListView.builder(
              itemCount: 101,
              itemBuilder: (context, index) {
                int year = 2000 + index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    Navigator.of(context).pop(year);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        this.selectedYear = DateTime(selectedYear);
        selectedMonth = null;
        selectedDate = null;
      });

      Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedDate(null);
      Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedMonth(null);
      Provider.of<TransactionPeriodProvider>(context, listen: false).setSelectedYear(DateTime(selectedYear));
    }
  }


  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const login()),
    );
  }

  Future<String> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData.data()?['username'] ?? "User";
    }
    return "User";
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).colorScheme.tertiary,
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 40, backgroundColor: Colors.yellow, child: Icon(Icons.person, size: 40)),
                    const SizedBox(height: 3),
                    const Text("Welcome!"),
                    const SizedBox(height: 3),
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? "");
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, _) {
                        return Consumer<PaymentMethodProvider>(
                          builder: (context, paymentMethodProvider, _) {
                            return DropdownButton<String>(
                              isExpanded: true,
                              value: paymentMethodProvider.selectedMethod,
                              underline: Container(),
                              items: _getDropdownItems(currencyProvider.currency),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  paymentMethodProvider.setPaymentMethod(newValue);
                                  widget.onPaymentMethodChanged?.call(newValue);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildListTile(Icons.home, "Home", () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen(onAccountChanged: (String account) {})))),
                    _buildListTile(Icons.monetization_on, "Currency", () => _showCurrencyDialog(context)),
                    _buildListTile(Icons.settings, "Settings", () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const settings_screen.Settings()))),
                    const SizedBox(height: 40),
                    const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 18), child: Text("Viewed By", style: TextStyle(fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 20),
                    _buildListTile(Icons.edit_calendar, selectedDate != null ? "${selectedDate!.toLocal()}".split(' ')[0] : "Choose Date", () => _selectDate(context)),
                    _buildListTile(Icons.date_range, selectedMonth != null ? "${selectedMonth!.month}/${selectedMonth!.year}" : "Choose Month", () => _selectMonth(context)),
                    _buildListTile(Icons.calendar_today, selectedYear != null ? "${selectedYear!.year}" : "Choose Year", () => _selectYear(context)),
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                        onTap: () => _logout(context),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems(String currency) {
    return [
      _buildDropdownItem("Cash", Icons.money, Colors.green, currency),
      _buildDropdownItem("Payment Card", Icons.credit_card, Colors.red, currency),
      _buildDropdownItem("Check", Icons.monetization_on, Colors.blue, currency),

    ];
  }

  DropdownMenuItem<String> _buildDropdownItem(String account, IconData icon, Color iconColor, String currency) {
    return DropdownMenuItem(
      value: account,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(account),
          const Spacer(),
          Text(currency, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Currency"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["LKR", "USD", "GBP"].map((currency) {
              return ListTile(
                title: Text(currency),
                onTap: () {
                  Provider.of<CurrencyProvider>(context, listen: false).setCurrency(currency);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
