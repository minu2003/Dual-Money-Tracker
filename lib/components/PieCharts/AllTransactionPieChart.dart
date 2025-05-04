import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../Provider/firestore_services.dart';
import '../../Provider/transaction_period_provider.dart';

class AllTransactionsPieChart extends StatelessWidget {
  final String paymentMethod;
  final FirestoreService _firestoreService = FirestoreService();

  AllTransactionsPieChart({required this.paymentMethod});

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

        double totalIncome = 0;
        double totalExpense = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] ?? 0).toDouble();

          if (data['type'] == 'income') {
            totalIncome += amount;
          } else if (data['type'] == 'expense') {
            totalExpense += amount.abs();
          }
        }

        final total = totalIncome + totalExpense;

        if (total == 0) {
          return const Center(child: Text("No data for selected period"));
        }

        return Container(
          color: Theme.of(context).colorScheme.background,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'All Piechart',
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
                    sections: [
                      PieChartSectionData(
                        value: totalIncome,
                        title: '${((totalIncome / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.green,
                        radius: 100,
                      ),
                      PieChartSectionData(
                        value: totalExpense,
                        title: '${((totalExpense / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.red,
                        radius: 100,
                      ),
                    ],
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(context, 'Income', Colors.green),
                  const SizedBox(width: 60),
                  _buildLegendItem(context, 'Expenses', Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem( BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface,)),
      ],
    );
  }
}
