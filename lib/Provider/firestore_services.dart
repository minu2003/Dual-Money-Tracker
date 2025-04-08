import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //personal
  CollectionReference _getUserTransactionsCollection(String paymentMethod) {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('personal_transactions')
          .doc(paymentMethod)
          .collection('transactions');
    } else {
      throw Exception('No authenticated user found');
    }
  }
  Future<void> addTransaction(Map<String, dynamic> transaction, {bool isBusiness = false}) async {
    try {
      String paymentMethod = transaction['paymentMethod'] ?? 'Cash';
      CollectionReference transactionsCollection =
      isBusiness ? _getBusinessTransactionsCollection(paymentMethod) : _getUserTransactionsCollection(paymentMethod);

      DocumentReference newTransaction = await transactionsCollection.add(transaction);
      print("Transaction added: ${newTransaction.id}");
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Stream<QuerySnapshot> getTransactions(
      String paymentMethod,
      DateTime? selectedDate,
      DateTime? selectedMonth,
      DateTime? selectedYear, {
        bool isBusiness = false,
  }) {
    try {
      Query query = (isBusiness
          ? _getBusinessTransactionsCollection(paymentMethod)
          : _getUserTransactionsCollection(paymentMethod))
          .orderBy('date', descending: true);

      if (selectedDate != null) {
        DateTime start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
        DateTime end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
        query = query.where('date', isGreaterThanOrEqualTo: start).where('date', isLessThanOrEqualTo: end);
      } else if (selectedMonth != null && selectedYear != null) {
        DateTime start = DateTime(selectedYear.year, selectedMonth.month, 1);
        DateTime end = DateTime(selectedYear.year, selectedMonth.month + 1, 0, 23, 59, 59);
        query = query.where('date', isGreaterThanOrEqualTo: start).where('date', isLessThanOrEqualTo: end);
      }

      return query.snapshots();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }


  Future<double> calculateNewBalance(double amount, String type, String paymentMethod, {bool isBusiness = false}) async {
    try {
      CollectionReference transactionsCollection = isBusiness ? _getBusinessTransactionsCollection(paymentMethod) : _getUserTransactionsCollection(paymentMethod);
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

  Stream<Map<String, double>> getFinancialSummary(String paymentMethod, {bool isBusiness = false}) {
    try {
      CollectionReference transactionsCollection = isBusiness ? _getBusinessTransactionsCollection(paymentMethod) : _getUserTransactionsCollection(paymentMethod);
      return transactionsCollection.snapshots().map((snapshot) {
        double totalIncome = 0.0;
        double totalExpenses = 0.0;

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          double amount = (data['amount'] ?? 0.0).toDouble();

          if (data['type'] == 'income') {
            totalIncome += amount;
          } else if (data['type'] == 'expense') {
            totalExpenses += amount.abs();
          }
        }

        double balance = totalIncome - totalExpenses;

        return {
          'totalIncome': totalIncome,
          'totalExpenses': totalExpenses,
          'balance': balance,
        };
      });
    } catch (e) {
      throw Exception('Failed to get financial summary: $e');
    }
  }
  //Business
  CollectionReference _getBusinessTransactionsCollection(String paymentMethod){
    User? user = _auth.currentUser;
    if(user != null){
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('Business_Transactions')
          .doc(paymentMethod)
          .collection('transactions');
    }else{
      throw Exception('No authenticated user found');
    }
  }

  Future<void> addBusinessCredit(Map<String, dynamic> transaction) async {
    try {
      String paymentMethod = transaction['paymentMethod'] ?? 'Cash';
      CollectionReference creditsCollection = _getBusinessTransactionsCollection(paymentMethod);
      DocumentReference newTransaction = await creditsCollection.add(transaction);
      print("Business credit added: ${newTransaction.id}");
    } catch (e) {
      throw Exception('Failed to add business credit: $e');
    }
  }
}
