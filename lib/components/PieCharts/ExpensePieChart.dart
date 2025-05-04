import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../Provider/firestore_services.dart';
import '../../Provider/transaction_period_provider.dart';
import '../../screens/view/pie_charts.dart';

class ExpensePieChart extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String paymentMethod;

  ExpensePieChart({required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    final period = Provider.of<TransactionPeriodProvider>(context);

    return StreamBuilder(
      stream: _firestoreService.getTransactions(
        paymentMethod,
        period.selectedDate,
        period.selectedMonth,
        period.selectedYear,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        Map<String, double> expenseMap = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['type'] == 'expense') {
            final category = data['category'] ?? 'Other';
            final amount = (data['amount'] ?? 0).toDouble().abs();
            expenseMap[category] = (expenseMap[category] ?? 0) + amount;
          }
        }

        if (expenseMap.isEmpty) {
          return const Center(child: Text("No expense data available."));
        }

        double total = expenseMap.values.fold(0, (sum, val) => sum + val);
        List<PieChartSectionData> data = [];
        List<Map<String, dynamic>> legend = [];
        int colorIndex = 0;

        expenseMap.forEach((key, value) {
          final percentage = (value / total) * 100;
          data.add(PieChartSectionData(
            value: value,
            title: '${percentage.toStringAsFixed(1)}%',
            color: CategoryColors.expenseColors[colorIndex % CategoryColors.expenseColors.length],
            radius: 100,
          ));
          legend.add({
            "label": key,
            "color": CategoryColors.expenseColors[colorIndex % CategoryColors.expenseColors.length],
          });
          colorIndex++;
        });

        return Container(
          color: Theme.of(context).colorScheme.background,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'Expense Pie Chart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 100),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: data,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              _buildLegend(context, legend),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context,List<Map<String, dynamic>> legends) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 30,
      runSpacing: 10,
      children: legends.map((legend) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: legend["color"],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              legend["label"],
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface,),
            ),
          ],
        );
      }).toList(),
    );
  }
}
