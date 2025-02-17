import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_app/Authentication/sign_in.dart';
import 'package:money_app/screens/view/home_screen.dart';
import 'package:money_app/screens/view/settings.dart' as settings_screen;
import 'currency_provider.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String? selectedMonthWithYear;
  String? selectedAccount = "Cash";
  String? selectedMonth;
  String? selectedYear;
  bool isMonthDropdownVisible = false;
  bool isYearDropdownVisible = false;

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  final List<String> years = [
    "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"
  ];

  void updateMonthWithYear() {
    if (selectedMonth != null && selectedYear != null) {
      selectedMonthWithYear = "$selectedMonth $selectedYear";
      } else if (selectedMonth != null) {
      selectedMonthWithYear = selectedMonth;
      } else {
      selectedMonthWithYear = null;
      }
  }

  Future<void> _logout(BuildContext context) async{
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const login())
    );
  }

  Future<String> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData.data()?['username'] ?? "User";
    }
    return "User";  // Return default if no user
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow,
                        ),
                        child: const Icon(Icons.person, size: 40),
                      ),
                    ],
                  ),
                  const Text("Welcome!"),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: ValueListenableBuilder<String>(
                                valueListenable: currencyNotifier,
                                builder: (context, currency, _) {
                                  return DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedAccount,
                                    underline: Container(),
                                    items: _getDropdownItems(currency),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedAccount = newValue;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text("Home"),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monetization_on),
                        title: const Text("Currency"),
                        onTap: () => currencyProvider(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text("Settings"),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const settings_screen.Settings()));
                        },
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 18),
                            child: Text(
                              "Viewed By",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: const Text("Year"),
                        onTap: () {
                          setState(() {
                            isYearDropdownVisible = !isYearDropdownVisible; // Toggle dropdown visibility
                          });
                        },
                      ),
                      if (isYearDropdownVisible) // Show dropdown when flag is true
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Select Year"),
                            value: selectedYear,
                            underline: Container(),
                            items: years
                                .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ))
                                .toList(),
                            onChanged: (String? newYear) {
                              setState(() {
                                selectedYear = newYear;
                                isYearDropdownVisible = false;
                                updateMonthWithYear();
                              });
                            },
                          ),
                        ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text("Month"),
                        onTap: () {
                          setState(() {
                            isMonthDropdownVisible = !isMonthDropdownVisible;
                          });
                        },
                      ),
                      if (isMonthDropdownVisible)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Select Month"),
                            value: selectedMonthWithYear,
                            underline: Container(),
                            items: months
                                .map((month) {
                              final combined = selectedYear != null
                                  ? "$month $selectedYear"
                                  : month;
                              return DropdownMenuItem(
                                value: combined,
                                child: Text(combined),
                              );
                            })
                                .toList(),
                            onChanged: (String? newMonthWithYear) {
                              setState(() {
                                selectedMonthWithYear = newMonthWithYear;
                              });
                            },
                          ),
                        ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _logout(context),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems(String currency) {
    return [
      _buildDropdownItem("All Accounts", Icons.sell_outlined, Colors.orange, currency),
      _buildDropdownItem("Cash", Icons.money, Colors.green, currency),
      _buildDropdownItem("Payment Card", Icons.credit_card, Colors.red, currency),
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
}
