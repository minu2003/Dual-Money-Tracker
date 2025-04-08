import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../../Provider/firestore_services.dart';
import '../../../../Provider/transaction_period_provider.dart';
import '../BusinessPiecharts.dart';

class debitPieChart extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String paymentMethod;

  debitPieChart({required this.paymentMethod});

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
        Map<String, double> debitMap = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['type'] == 'Debit') {
            final category = data['category'] ?? 'Other';
            final amount = (data['amount'] ?? 0).toDouble().abs();
            debitMap[category] = (debitMap[category] ?? 0) + amount;
          }
        }

        if (debitMap.isEmpty) {
          return const Center(child: Text("No expense data available."));
        }

        double total = debitMap.values.fold(0, (sum, val) => sum + val);
        List<PieChartSectionData> data = [];
        List<Map<String, dynamic>> legend = [];
        int colorIndex = 0;

        debitMap.forEach((key, value) {
          final percentage = (value / total) * 100;
          data.add(PieChartSectionData(
            value: value,
            title: '${percentage.toStringAsFixed(1)}%',
            color: categoryColors.debitColors[colorIndex % categoryColors.debitColors.length],
            radius: 100,
          ));
          legend.add({
            "label": key,
            "color": categoryColors.debitColors[colorIndex % categoryColors.debitColors.length],
          });
          colorIndex++;
        });

        return Container(
          color: const Color(0xFFECECEC),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'debit Pie Chart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
              _buildLegend(legend),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> legends) {
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
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        );
      }).toList(),
    );
  }
}
