import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Provider/firestore_services.dart';

//personal Account (for income_expense.dart)

void showEditTransactionDialog(
    BuildContext context,
    String transactionId,
    Map<String, dynamic> transaction,
    FirestoreService firestoreService,
    String selectedPaymentMethod,
    String currentAccount,{
      bool isBusiness = false,
      required List<Map<String, dynamic>> categoryList,
})
{
  final titleController = TextEditingController(text: transaction['title']);
  final amountController = TextEditingController(text: transaction['amount'].toString());
  String selectedCategory = transaction['category'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(labelText: 'Category'),
              items: categoryList.map((category) {
                return DropdownMenuItem<String>(
                  value: category['label'],
                  child: Text(category['label']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedTransaction = {
                'title': titleController.text,
                'amount': double.tryParse(amountController.text) ?? 0.0,
                'category': selectedCategory,
                'date': DateTime.now(),
                'type': transaction['type'],
              };
              firestoreService.updateTransaction(
                transactionId,
                updatedTransaction,
                selectedPaymentMethod,
                isBusiness: currentAccount == 'business',
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

//business Account (for credit_debit.dart)

void businessEditTransactionDialog(
    BuildContext context,
    String transactionId,
    Map<String, dynamic> transaction,
    FirestoreService firestoreService,
    String selectedPaymentMethod,
    String currentAccount,{
      bool isBusiness = false,
      required List<Map<String, dynamic>> categoryList,
    })
{
  final titleController = TextEditingController(text: transaction['title']);
  final amountController = TextEditingController(text: transaction['amount'].toString());
  String selectedCategory = transaction['category'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(labelText: 'Category'),
              items: categoryList.map((category) {
                return DropdownMenuItem<String>(
                  value: category['label'],
                  child: Text(category['label']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedTransaction = {
                'title': titleController.text,
                'amount': double.tryParse(amountController.text) ?? 0.0,
                'category': selectedCategory,
                'date': DateTime.now(),
                'type': transaction['type'],
              };
              firestoreService.updateTransaction(
                transactionId,
                updatedTransaction,
                selectedPaymentMethod,
                isBusiness: true,
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

