import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_app/components/appbar.dart';
import 'package:provider/provider.dart';
import '../../../Provider/firestore_services.dart';
import '../../../Provider/paymentMethod_provider.dart';
import '../../../Provider/transaction_period_provider.dart';
import '../../../components/bottom_navbar.dart';
import '../../../components/currency_provider.dart';
import '../../../components/edit_transaction.dart';
import 'expense_add.dart';
import 'income_add.dart';

class income_expense extends StatefulWidget {
  final int initialTabIndex;
  const income_expense({super.key, this.initialTabIndex = 0});

  @override
  State<income_expense> createState() => _income_expenseState();
}

class _income_expenseState extends State<income_expense> with SingleTickerProviderStateMixin{
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  String currentAccount = 'personal';
  String selectedIncomeCategory = "All";
  String selectedExpenseCategory = "All";

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

  final List<Map<String, dynamic>> incomes = [
    {"label": "All", "color": Colors.lightBlue, "icon": Icons.wallet},
    {"label": "Salary", "color": Colors.lightBlue, "icon": Icons.attach_money},
    {"label": "Deposits", "color": Colors.lightBlue, "icon": Icons.account_balance},
    {"label": "Savings", "color": Colors.lightBlue, "icon": Icons.savings},
  ];
  final List<Map<String, dynamic>> expenses = [
    {"label": "All", "color": Colors.lightBlue, "icon": Icons.wallet},
    {"label": "Gas-Filling", "color": Colors.lightBlue, "icon": Icons.local_gas_station},
    {"label": "Car", "color": Colors.lightBlue, "icon": Icons.directions_car},
    {"label": "Grocery", "color": Colors.lightBlue, "icon": Icons.shopping_cart},
    {"label": "Dine In", "color": Colors.lightBlue, "icon": Icons.fastfood},
    {"label": "Bill", "color": Colors.lightBlue, "icon": Icons.receipt},
    {"label": "Communication", "color": Colors.lightBlue, "icon": Icons.phone},
    {"label": "Travel", "color": Colors.lightBlue, "icon": Icons.flight},
    {"label": "Health", "color": Colors.lightBlue, "icon": Icons.local_hospital},
    {"label": "Entertainment", "color": Colors.lightBlue, "icon": Icons.tv},
    {"label": "House", "color": Colors.lightBlue, "icon": Icons.home},
    {"label": "Gift", "color": Colors.lightBlue, "icon": Icons.card_giftcard},
    {"label": "Loan", "color": Colors.lightBlue, "icon": Icons.money},
    {"label": "Cloths", "color": Colors.lightBlue, "icon": Icons.checkroom},
    {"label": "Others", "color": Colors.lightBlue, "icon": Icons.category},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: Image.asset(
                "assets/dualLogo.png",
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
            Tab(text: 'incomes',),
            Tab(text: 'Expenses',)
                  ],
            labelColor: Colors.lightBlue,
            indicatorColor: Colors.lightBlue,
                  ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildTransactionList("income", selectedIncomeCategory, incomes,
                          (category) => setState(() => selectedIncomeCategory = category)),
                  buildTransactionList("expense", selectedExpenseCategory, expenses,
                          (category) => setState(() => selectedExpenseCategory = category)),
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
                  showAddExpenseDialog(context);
                },
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  showAddIncomeDialog(context);
                },
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
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
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[300],
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
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getTransactions(
                selectedPaymentMethod,
                selectedDate,
                selectedMonth,
                selectedYear),
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
                date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day
                    : true;

                bool isMonthMatching = selectedMonth != null ?
                date.year == selectedMonth.year && date.month == selectedMonth.month
                    : true;

                bool isYearMatching = selectedYear != null ?
                date.year == selectedYear.year
                    : true;

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
                  final formattedDate =
                  DateFormat("MMMM d, yyyy h:mm a").format(date);

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
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
                              backgroundColor: type == 'income'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                type == 'income'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: type == 'income' ? Colors.green : Colors.red,
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
                          "${type == 'expense' ? '-' : '+'} $currency ${(transaction['amount'] ?? 0.0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: type == 'expense' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              showEditTransactionDialog(
                                context,
                                transactionId,
                                transaction,
                                _firestoreService,
                                selectedPaymentMethod,
                                currentAccount,
                                isBusiness: false,
                                categoryList: type == 'income' ? incomes : expenses,
                              );
                            } else if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Transaction'),
                                  content: Text('Are you sure you want to delete this transaction?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel",style: TextStyle(color: Colors.blue)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _firestoreService.deleteTransaction(
                                          transactionId,
                                          selectedPaymentMethod,
                                            isBusiness: currentAccount == 'business',
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface, size: 20,),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Theme.of(context).colorScheme.onSurface, size: 20,),
                                    SizedBox(width: 8,),
                                    Text('Delete'),
                                  ],
                                ),
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


