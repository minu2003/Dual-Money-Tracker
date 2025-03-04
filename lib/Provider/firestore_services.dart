import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getUserTransactionsCollection() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('personal_transactions');
    } else {
      throw Exception('No authenticated user found');
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      CollectionReference transactionsCollection = _getUserTransactionsCollection();
      String paymentMethod = transaction['paymentMethod'] ?? 'Cash';
      await transactionsCollection.doc(paymentMethod).collection('transactions').add(transaction);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Stream<QuerySnapshot> getTransactions(String paymentMethod) {
    try {
      CollectionReference transactionsCollection = _getUserTransactionsCollection();

      if (paymentMethod == 'All Accounts') {
        return transactionsCollection
            .snapshots();
      } else {
        return transactionsCollection
            .doc(paymentMethod)
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots();
      }
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }


  Future<double> calculateNewBalance(double amount, String type, String paymentMethod) async {
    try {
      CollectionReference transactionsCollection = _getUserTransactionsCollection().doc(paymentMethod).collection('transactions');
      QuerySnapshot snapshot = await transactionsCollection.orderBy('date', descending: true).limit(1).get();

      double lastBalance = 0.0;
      if (snapshot.docs.isNotEmpty) {
        var docData = snapshot.docs.first.data() as Map<String, dynamic>;
        lastBalance = (docData['balance'] ?? 0.0).toDouble();
      }

      return type == 'income' ? lastBalance + amount : lastBalance - amount;
    } catch (e) {
      throw Exception('Failed to calculate balance: $e');
    }
  }

  Future<Map<String, double>> getFinancialSummary(String paymentMethod) async {
    try {
      CollectionReference transactionsCollection;
      if (paymentMethod == 'All Accounts') {
        transactionsCollection = _getUserTransactionsCollection();
      } else {
        transactionsCollection = _getUserTransactionsCollection().doc(paymentMethod).collection('transactions');
      }

      QuerySnapshot snapshot = await transactionsCollection.get();
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
    } catch (e) {
      throw Exception('Failed to get financial summary: $e');
    }
  }
}