import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_app/components/PieCharts/AllTransactionPieChart.dart';
import '../../components/PieCharts/ExpensePieChart.dart';
import '../../components/PieCharts/IncomePieChart.dart';

class CategoryColors{
  static const incomeColors = [
    Colors.green,
    Colors.lightGreen,
    Colors.greenAccent,
  ];
  static const expenseColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.amberAccent,
    Colors.brown,
    Colors.purpleAccent,
    Colors.cyanAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.tealAccent,
    Colors.indigo,
    Colors.pinkAccent,
  ];
}

class PiechartScreen extends StatefulWidget {
  final int initialTabIndex;
  const PiechartScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PiechartScreen> createState() => _PiechartScreenState();
}

class _PiechartScreenState extends State<PiechartScreen>
    with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

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
                "assets/Logo.png",
                height: 50,
              ),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'All',),
                  Tab(text: 'Income',),
                  Tab(text: 'Expense',)

                ],
                labelColor: Colors.lightBlue,
                indicatorColor: Colors.lightBlue,
              ),
              Expanded(
                  child: TabBarView(
                      controller: _tabController,
                      children: [
                        AllTransactionsPieChart(
                            paymentMethod: 'Cash'
                        ),
                        IncomePieChart(paymentMethod: 'Cash'),
                        ExpensePieChart(paymentMethod: 'Cash'),
                      ]))
            ],
          )),
    );
  }
}
