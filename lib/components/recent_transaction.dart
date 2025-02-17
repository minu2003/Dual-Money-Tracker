import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Provider/firestore_services.dart';
import 'package:intl/intl.dart';

class RecentTransactions extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final transactions = snapshot.data!.docs;
        double balance = 0.0;

        List<Map<String,dynamic>> transactionsList = transactions.map((doc){
          final data = doc.data() as Map<String, dynamic>;
          return{
            'title': data['title'],
            'amount': data['amount'],
            'type': data['type'],
            'date': (data['date'] as Timestamp).toDate(),
          };
        }).toList();

        transactionsList.sort((a, b) => a['date'].compareTo(b['date']));

        for (var transaction in transactionsList) {
          balance += transaction['type'] == 'income' ? transaction['amount'] : -transaction['amount'];
          transaction['balance'] = balance;
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index].data() as Map<String, dynamic>;
            final date = (transaction['date'] as Timestamp).toDate();
            final formattedDate = DateFormat("MMMM d, yyyy h:mm a").format(date);

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
                        "${transaction['amount'] < 0 ? '-' : '+'} LKR ${(transaction['amount'] ?? 0.0).abs().toStringAsFixed(2)}",
                        style: TextStyle(
                          color: transaction['amount'] < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "LKR ${(transaction['balance']?? 0.0).toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}