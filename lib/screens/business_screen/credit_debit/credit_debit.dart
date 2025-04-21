import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app/components/appbar.dart';
import 'package:money_app/screens/business_screen/credit_debit/credit_add.dart';
import 'package:money_app/screens/business_screen/credit_debit/debit_add.dart';
import 'package:provider/provider.dart';
import '../../../Provider/firestore_services.dart';
import '../../../Provider/paymentMethod_provider.dart';
import '../../../Provider/transaction_period_provider.dart';
import '../../../components/bottom_navbar.dart';
import '../../../components/currency_provider.dart';
import '../../../components/edit_transaction.dart';

class credit_debit extends StatefulWidget {
  final int initialTabIndex;
  const credit_debit({super.key, this.initialTabIndex = 0});

  @override
  State<credit_debit> createState() => _CreditDebitScreenState();
}

class _CreditDebitScreenState extends State<credit_debit> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  String currentAccount = 'Business';
  String selectedCreditCategory = "All";
  String selectedDebitCategory = "All";

  void handleAccountChange(String account){
    setState(() {
      currentAccount = account;
    });
    print("Switched to: $account");
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> credit = [
    {"label": "All", "color": Colors.lightBlue, "icon": Icons.wallet},
    {"label": "Sales Revenue", "color": Colors.lightBlue, "icon": Icons.account_balance},
    {"label": "Loans", "color": Colors.lightBlue, "icon": Icons.monetization_on},
    {"label": "Investments", "color": Colors.lightBlue, "icon": Icons.savings},
    {"label": "Refunds", "color": Colors.lightBlue, "icon": Icons.savings},
  ];
  final List<Map<String, dynamic>> debit = [
    {"label": "All", "color": Colors.lightBlue, "icon": Icons.wallet},
    {"label": "Rent", "color": Colors.lightBlue, "icon": Icons.house},
    {"label": "Salaries and Wages", "color": Colors.lightBlue, "icon": Icons.inventory},
    {"label": "Advertising/Marketing", "color": Colors.lightBlue, "icon": Icons.ads_click},
    {"label": "Taxes & Fees", "color": Colors.lightBlue, "icon": Icons.money},
    {"label": "Loan Repayments", "color": Colors.lightBlue, "icon": Icons.attach_money},
    {"label": "Travel & Transportation", "color": Colors.lightBlue, "icon": Icons.directions_bus},
    {"label": "Internet & Communication", "color": Colors.lightBlue, "icon": Icons.signal_wifi_statusbar_connected_no_internet_4_rounded},
    {"label": "Software Subscriptions", "color": Colors.lightBlue, "icon": Icons.subscriptions},
    {"label": "Others", "color": Colors.lightBlue, "icon": Icons.category},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: Image.asset(
                "assets/LogoBusiness.png",
                height: 50,
              ),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Credits'),
                Tab(text: 'Debits'),
              ],
              labelColor: Colors.lightBlue,
              indicatorColor: Colors.lightBlue,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildTransactionList("credit", selectedCreditCategory, credit,
                          (category) => setState(() => selectedCreditCategory = category)),
                  buildTransactionList("Debit", selectedDebitCategory, debit,
                          (category) => setState(() => selectedDebitCategory = category)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
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

  Widget buildTransactionList(String type, String selectedCategory,
      List<Map<String, dynamic>> categories, Function(String) onCategoryTap) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    final selectedPaymentMethod = Provider.of<PaymentMethodProvider>(context).selectedMethod;
    final selectedDate = Provider.of<TransactionPeriodProvider>(context).selectedDate;
    final selectedMonth = Provider.of<TransactionPeriodProvider>(context).selectedMonth;
    final selectedYear = Provider.of<TransactionPeriodProvider>(context).selectedYear;

    return Column(
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return GestureDetector(
                onTap: () => onCategoryTap(category["label"]),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selectedCategory == category["label"]
                        ? Colors.blueAccent
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(category["icon"], size: 20, color: Colors.white),
                      SizedBox(width: 5),
                      Text(category["label"], style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getTransactions(
              selectedPaymentMethod,
              selectedDate,
              selectedMonth,
              selectedYear,
              isBusiness: true,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final transactions = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                if (data == null) return false;

                final date = (data['date'] as Timestamp).toDate();

                bool isDateMatching = selectedDate != null ?
                date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day : true;

                bool isMonthMatching = selectedMonth != null ?
                date.year == selectedMonth.year && date.month == selectedMonth.month : true;

                bool isYearMatching = selectedYear != null ?
                date.year == selectedYear.year : true;

                return data['type'] == type &&
                    (selectedCategory == "All" || data['category'] == selectedCategory) &&
                    isDateMatching &&
                    isMonthMatching &&
                    isYearMatching;
              }).toList();

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index].data() as Map<String, dynamic>;
                  final transactionId = transactions[index].id;
                  final date = (transaction['date'] as Timestamp).toDate();
                  final formattedDate = DateFormat("MMMM d, yyyy h:mm a").format(date);

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: transaction['type'] == 'credit'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                transaction['type'] == 'credit'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: transaction['type'] == 'credit' ? Colors.green : Colors.red,
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction['title'],
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Text(formattedDate,
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          "${transaction['type'] == 'debit' ? '-' : '+'} $currency ${(transaction['amount'] ?? 0.0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: transaction['type'] == 'debit' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              businessEditTransactionDialog(
                                context,
                                transactionId,
                                transaction,
                                _firestoreService,
                                selectedPaymentMethod,
                                currentAccount,
                                isBusiness: true,
                                categoryList: type == 'credit' ? credit : debit,
                              );
                            } else if (value == 'delete') {
                              _firestoreService.deleteTransaction(
                                transactionId,
                                selectedPaymentMethod,
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
