import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../Provider/firestore_services.dart';
import '../../../../Provider/transaction_period_provider.dart';
import 'package:provider/provider.dart';
import '../BusinessPiecharts.dart';

class creditPieChart extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String paymentMethod;

  creditPieChart({required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    final period = Provider.of<TransactionPeriodProvider>(context);

    return StreamBuilder(
      stream: _firestoreService.getTransactions(
        paymentMethod,
        period.selectedDate,
        period.selectedMonth,
        period.selectedYear,
        isBusiness: true,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        Map<String, double> creditMap = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['type'] == 'credit') {
            final category = data['category'] ?? 'Other';
            final amount = (data['amount'] ?? 0).toDouble();
            creditMap[category] = (creditMap[category] ?? 0) + amount;
          }
        }

        if (creditMap.isEmpty) {
          return const Center(child: Text("No income data available."));
        }

        double total = creditMap.values.fold(0, (sum, val) => sum + val);
        List<PieChartSectionData> data = [];
        List<Map<String, dynamic>> legend = [];
        int colorIndex = 0;

        creditMap.forEach((key, value) {
          final percentage = (value / total) * 100;
          data.add(PieChartSectionData(
            value: value,
            title: '${percentage.toStringAsFixed(1)}%',
            color: categoryColors.creditColors[colorIndex % categoryColors.creditColors.length],
            radius: 100,
          ));
          legend.add({
            "label": key,
            "color": categoryColors.creditColors[colorIndex % categoryColors.creditColors.length]
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
                'Credit Pie Chart',
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
              _buildLegend(context,legend),
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
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        );
      }).toList(),
    );
  }
}
