import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_app/components/drawer_screen.dart';
import 'package:money_app/components/recent_transaction.dart';
import 'package:money_app/screens/business_screen/components/B_bottom_navbar.dart';
import 'package:money_app/screens/business_screen/credit_debit/credit_debit.dart';
import 'package:money_app/screens/view/income_expense/income_expemses.dart';
import 'package:provider/provider.dart';
import '../../Provider/firestore_services.dart';
import '../../Provider/transaction_period_provider.dart';
import '../../components/bottom_navbar.dart';
import '../../components/currency_provider.dart';
import 'components/recentTransaction.dart';
import 'components/B_appbar.dart';
import 'credit_debit/credit_add.dart';
import 'credit_debit/debit_add.dart';

class BusinessHomeScreen extends StatelessWidget {
  final Function(String) onAccountChanged;
  const BusinessHomeScreen({super.key, required this.onAccountChanged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DropdownExample(onAccountChanged: onAccountChanged),
    );
  }
}

class DropdownExample extends StatefulWidget {
  final Function(String) onAccountChanged;
  const DropdownExample({super.key, required this.onAccountChanged});

  @override
  State<DropdownExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String currentAccount = 'Business';
  String paymentMethod = 'Cash';
  double totalCredit = 0.0;
  double totalDebit = 0.0;
  double balance = 0.0;

  @override
  void initState() {
    super.initState();

    fetchFinancialSummary(paymentMethod);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionPeriodProvider>(context, listen: false)
          .addListener(() {
        fetchFinancialSummary(paymentMethod);
      });
    });
  }


  void fetchFinancialSummary(String paymentMethod) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transactionProvider = Provider.of<TransactionPeriodProvider>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime startDate, endDate;

    if (transactionProvider.selectedDate != null) {
      startDate = transactionProvider.selectedDate!;
      endDate = startDate.add(Duration(days: 1));
    } else if (transactionProvider.selectedMonth != null) {
      startDate = DateTime(transactionProvider.selectedMonth!.year, transactionProvider.selectedMonth!.month, 1);
      endDate = DateTime(transactionProvider.selectedMonth!.year, transactionProvider.selectedMonth!.month + 1, 1);
    } else if (transactionProvider.selectedYear != null) {
      startDate = DateTime(transactionProvider.selectedYear!.year, 1, 1);
      endDate = DateTime(transactionProvider.selectedYear!.year + 1, 1, 1);
    } else {

      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 1);
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('Business_Transactions')
        .doc(paymentMethod)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .snapshots()
        .listen((snapshot) {
      double credit = 0.0;
      double Debit = 0.0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double amount = (data['amount'] ?? 0.0).toDouble();

        if (data['type'] == 'credit') {
          credit += amount;
        } else if (data['type'] == 'Debit') {
          Debit += amount.abs();
        }
      }

      if (mounted) {
        setState(() {
          totalCredit = credit;
          totalDebit = Debit;
          balance = totalCredit - totalDebit;
        });
      }
    });
  }

  void handleAccountChange(String account) {
    setState(() {
      currentAccount = account;
    });
    fetchFinancialSummary(account);
    widget.onAccountChanged(account);
    print("Switched to: $account");
  }

  void handlePaymentMethodChange(String selectedPaymentMethod) {
    setState(() {
      paymentMethod = selectedPaymentMethod;
    });
    fetchFinancialSummary(paymentMethod);
    print("Switched to payment method: $selectedPaymentMethod");
  }


  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    return Scaffold(
      drawer: DrawerScreen(onPaymentMethodChanged: handlePaymentMethodChange),
      appBar: customAppBar(onAccountChanged: handleAccountChange, currentAccount: currentAccount,),
      body: Container(
        color: Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, right: 21, left: 21),
              padding: const EdgeInsets.all(20),
              height: 212,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5efce8), Color(0xFF736efe)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "February",
                    style: TextStyle(color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  Text(
                    "Month",
                    style: TextStyle(color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 0.9,
                    ),
                  ),

                  Center(
                    child: Text("Balance",
                      style: TextStyle(color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$currency",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          balance.toStringAsFixed(0),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              height: 1.2
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          ".00",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 19.0,
                              child: Icon(
                                Icons.arrow_downward,
                                color: Colors.red,
                                size: 24.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 5,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Debits",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  totalDebit.toStringAsFixed(0),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      height: 1.2,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(".00",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 18.0,
                              child: Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 24.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 5,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Credit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  totalCredit.toStringAsFixed(0),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      height: 1.2,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(".00",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20, left: 20, top: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => credit_debit(initialTabIndex: 0))
                          );
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white
                        ),
                        child: const Text(
                          "Credits",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => credit_debit(initialTabIndex: 1))
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Debits",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            recentTransactions(isBusiness: true,)
          ],
        ),
      ),
      bottomNavigationBar: B_BottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 65),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Transform.scale(
              scale: 1.8,
              child: FloatingActionButton(
                onPressed: () {
                  AddDebitDialog(context);
                },
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.remove,
                  color: Colors.red,
                ),
              ),
            ),
            Transform.scale(
              scale: 1.8,
              child: FloatingActionButton(
                onPressed: () {
                  AddCreditDialog(context);
                },
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
