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
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize colors here
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
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
    return "User";
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
                  SizedBox(height: 3,),
                  const Text("Welcome!"),
                  SizedBox(height: 3,),
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
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          selectedDate != null
                              ? "${selectedDate!.toLocal()}".split(' ')[0]
                              : "Select Date",
                        ),
                        onTap: () => _selectDate(context),
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
      _buildDropdownItem("Cash", Icons.money, Colors.green, currency),
      _buildDropdownItem("Payment Card", Icons.credit_card, Colors.red, currency),
      _buildDropdownItem("Checks", Icons.sell_outlined, Colors.orange, currency),
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
