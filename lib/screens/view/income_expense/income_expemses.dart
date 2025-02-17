import 'package:flutter/material.dart';
import 'package:money_app/components/appbar.dart';
import '../../../components/bottom_navbar.dart';
import 'expense_add.dart';
import 'income_add.dart';

class income_expense extends StatefulWidget {
  final int initialTabIndex;
  const income_expense({super.key, this.initialTabIndex = 0});

  @override
  State<income_expense> createState() => _income_expenseState();
}

class _income_expenseState extends State<income_expense> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  String currentAccount = 'personal';

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
    {"label": "Health", "color": Colors.lightBlue, "icon": Icons.local_hospital},
    {"label": "Car", "color": Colors.lightBlue, "icon": Icons.directions_car},
    {"label": "Grocery", "color": Colors.lightBlue, "icon": Icons.shopping_cart},
    {"label": "Bill", "color": Colors.lightBlue, "icon": Icons.receipt},
    {"label": "Communication", "color": Colors.lightBlue, "icon": Icons.phone},
    {"label": "House", "color": Colors.lightBlue, "icon": Icons.home},
    {"label": "Gift", "color": Colors.lightBlue, "icon": Icons.card_giftcard},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onAccountChanged: handleAccountChange),
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
                  //income
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: incomes.length,
                          itemBuilder: (context, index) {
                            final income = incomes[index];
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              child: IncomeExpenseChip(
                                label: income['label'],
                                color: income['color'],
                                icon: income['icon'],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  //expense
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              child: IncomeExpenseChip(
                                label: expense['label'],
                                color: expense['color'],
                                icon: expense['icon'],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
                  showAddIncomeDialog(context);
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
class IncomeExpenseChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const IncomeExpenseChip({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

