import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../Provider/firestore_services.dart';
import 'package:intl/intl.dart';

import '../Provider/paymentMethod_provider.dart';
import '../Provider/transaction_period_provider.dart';
import 'currency_provider.dart';

class RecentTransactions extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context).currency;
    final selectedPaymentMethod = Provider.of<PaymentMethodProvider>(context).selectedMethod;
    final selectedPeriod = Provider.of<TransactionPeriodProvider>(context).selectedPeriod;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getTransactions(selectedPaymentMethod),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final transactions = snapshot.data!.docs;

        if (transactions.isEmpty) {
          return Center(child: Text("No recent transactions"));
        }

        List<Map<String,dynamic>> transactionsList = transactions.map((doc){
          final data = doc.data() as Map<String, dynamic>;
          return{
            'title': data['title'],
            'amount': data['amount'],
            'type': data['type'],
            'date': (data['date'] as Timestamp).toDate(),
          };
        }).toList();

        DateTime now = DateTime.now();
        transactionsList = transactionsList.where((transaction) {
          DateTime transactionDate = transaction['date'];
          if (selectedPeriod == TransactionPeriod.day) {
            return transactionDate.year == now.year &&
                transactionDate.month == now.month &&
                transactionDate.day == now.day;
          } else if (selectedPeriod == TransactionPeriod.month) {
            return transactionDate.year == now.year &&
                transactionDate.month == now.month;
          } else if (selectedPeriod == TransactionPeriod.year) {
            return transactionDate.year == now.year;
          }
          return true;
        }).toList();

        double balance = 0.0;
        transactionsList.sort((a, b) => a['date'].compareTo(b['date']));

        for (var transaction in transactionsList) {
          double amount = transaction['amount'] ?? 0.0;
          String type = transaction['type'] ?? 0.0;

          if (type == 'income') {
            balance += amount;
          } else if (type == 'expense') {
            balance -= amount.abs();
          }

          transaction['balance'] = balance;
        }

        final recentTransactions = transactionsList.take(10).toList();

        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: recentTransactions.map((transaction) {
                final formattedDate = DateFormat("MMMM d, yyyy h:mm a").format(transaction['date']);

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: transaction['type'] == 'income' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            child: Icon(
                              transaction['type'] == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                              color: transaction['type'] == 'income' ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transaction['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text(formattedDate, style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${transaction['type'] == 'expense' ? '-' : '+'} $currency ${(transaction['amount'] ?? 0.0).toStringAsFixed(2)}",
                            style: TextStyle(
                              color: transaction['type'] == 'expense' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "$currency ${(transaction['balance'] ?? 0.0).toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}