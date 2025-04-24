import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_app/components/PieCharts/AllTransactionPieChart.dart';
import 'package:provider/provider.dart';

import '../../../Provider/paymentMethod_provider.dart';
import 'Business_Piecharts/B_AllTransactionpiechart.dart';
import 'Business_Piecharts/CreditPiechart.dart';
import 'Business_Piecharts/DebitPiechart.dart';

class categoryColors{
  static const creditColors = [
    Colors.green,
    Colors.lightGreen,
    Colors.greenAccent,
    Colors.lightGreenAccent
  ];
  static const debitColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.amberAccent,
    Colors.brown,
    Colors.cyanAccent,
    Colors.indigo,
    Colors.pinkAccent,
  ];
}

class businessPiechartScreen extends StatefulWidget {
  final int initialTabIndex;
  const businessPiechartScreen({super.key, this.initialTabIndex = 0});

  @override
  State<businessPiechartScreen> createState() => _PiechartScreenState();
}

class _PiechartScreenState extends State<businessPiechartScreen>
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
    final selectedMethod = Provider.of<PaymentMethodProvider>(context).selectedMethod;
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
          length: 3,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'All',),
                  Tab(text: 'Credit',),
                  Tab(text: 'Debit',)

                ],
                labelColor: Colors.lightBlue,
                indicatorColor: Colors.lightBlue,
              ),
              Expanded(
                  child: TabBarView(
                      controller: _tabController,
                      children: [
                        B_AllTransactionsPieChart(
                            paymentMethod: selectedMethod
                        ),
                        creditPieChart(paymentMethod: selectedMethod),
                        debitPieChart(paymentMethod: selectedMethod),
                      ]))
            ],
          )),
    );
  }
}
