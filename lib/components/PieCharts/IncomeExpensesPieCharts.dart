import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeExpensesPieCharts extends StatelessWidget {
  final List<PieChartSectionData> incomeData;
  final List<PieChartSectionData> expenseData;

  const IncomeExpensesPieCharts({
    Key? key,
    required this.incomeData,
    required this.expenseData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChartCard(
          title: "Income Pie Chart",
          pieData: incomeData,
          legends: [
            {"color": incomeData[0].color, "label": "Salary"},
            {"color": incomeData[1].color, "label": "Business"},
            {"color": incomeData[2].color, "label": "Investments"},
          ],
        ),
        _buildChartCard(
          title: "Expense Pie Chart",
          pieData: expenseData,
          legends: [
            {"color": expenseData[0].color, "label": "Rent"},
            {"color": expenseData[1].color, "label": "Food"},
            {"color": expenseData[2].color, "label": "Utilities"},
            {"color": expenseData[3].color, "label": "Entertainment"},
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required List<PieChartSectionData> pieData,
    required List<Map<String, dynamic>> legends,
  }) {
    return Card(
      color: const Color(0xFFECECEC),
      margin: const EdgeInsets.all(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: pieData,
                  centerSpaceRadius: 30,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildLegend(legends),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> legends) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 15,
      runSpacing: 10,
      children: legends.map((legend) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: legend["color"],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              legend["label"],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
