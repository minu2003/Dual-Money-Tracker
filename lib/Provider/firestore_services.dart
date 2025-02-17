import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _transactionsCollection =
  FirebaseFirestore.instance.collection('transactions');

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await _transactionsCollection.add(transaction);
  }

  Stream<QuerySnapshot> getTransactions() {
    return _transactionsCollection.orderBy('date', descending: false).snapshots();
  }
  Future<double> calculateNewBalance(double amount, String type) async {
    QuerySnapshot snapshot = await _transactionsCollection.orderBy('date', descending: true).limit(1).get();

    double lastBalance = 0.0;
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs.first.data() as Map<String, dynamic>;
      lastBalance = (docData['balance'] ?? 0.0).toDouble();
    }

    return type == 'income' ? lastBalance + amount : lastBalance - amount;
  }

  Future<Map<String, double>> getFinancialSummary() async {
    QuerySnapshot snapshot = await _transactionsCollection.get();

    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    double balance = 0.0;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double amount = (data['amount'] ?? 0.0).toDouble();

      if (data['type'] == 'income') {
        totalIncome += amount;
      } else if (data['type'] == 'expense') {
        totalExpenses += amount;
      }
    }

    balance = totalIncome - totalExpenses;

    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
    };
  }
}