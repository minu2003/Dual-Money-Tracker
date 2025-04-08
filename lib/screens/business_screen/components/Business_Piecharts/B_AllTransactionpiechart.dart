import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../../Provider/firestore_services.dart';
import '../../../../Provider/transaction_period_provider.dart';

class B_AllTransactionsPieChart extends StatelessWidget {
  final String paymentMethod;
  final FirestoreService _firestoreService = FirestoreService();

  B_AllTransactionsPieChart({required this.paymentMethod});

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

        double totalCredit = 0;
        double totalDebit = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] ?? 0).toDouble();

          if (data['type'] == 'credit') {
            totalCredit += amount;
          } else if (data['type'] == 'Debit') {
            totalDebit += amount.abs();
          }
        }

        final total = totalCredit + totalDebit;

        if (total == 0) {
          return const Center(child: Text("No data for selected period"));
        }

        return Container(
          color: const Color(0xFFECECEC),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'All Piechart',
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
                    sections: [
                      PieChartSectionData(
                        value: totalCredit,
                        title: '${((totalCredit / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.green,
                        radius: 100,
                      ),
                      PieChartSectionData(
                        value: totalDebit,
                        title: '${((totalDebit / total) * 100).toStringAsFixed(0)}%',
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
                  _buildLegendItem('credit', Colors.green),
                  const SizedBox(width: 60),
                  _buildLegendItem('Debit', Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}
