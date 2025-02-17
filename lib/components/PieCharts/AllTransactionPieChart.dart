import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AllTransactionsPieChart extends StatelessWidget {
  final double incomes;
  final double expenses;

  const AllTransactionsPieChart({
    Key? key,
    required this.incomes,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: incomes,
                  title: '60%',
                  color: Colors.green,
                  radius: 100,
                ),
                PieChartSectionData(
                  value: expenses,
                  title: '40%',
                  color: Colors.red,
                  radius: 100,
                ),
              ],
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        SizedBox(height: 100,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Income',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(width: 60),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Expenses',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            )
          ],
        )
      ],
    );

  }
}
