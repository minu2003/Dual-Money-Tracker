import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/firestore_services.dart';
import '../../../Provider/paymentMethod_provider.dart';

final FirestoreService _firestoreService = FirestoreService();

void AddIncomeDialog (BuildContext context){
  String? selectedCategory;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.account_balance, "label": "Deposits"},
    {"icon": Icons.monetization_on, "label": "Salary"},
    {"icon": Icons.savings, "label": "Savings"},
  ];
  String selectedPaymentMethod = Provider.of<PaymentMethodProvider>(context, listen: false).selectedMethod;

  showDialog(
      context: context,
      builder: (BuildContext context){
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child:  Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                        fontSize: 14
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                        fontSize: 14
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  value: selectedCategory,
                  hint: Text("Select Category"),
                  items: categories.map((category){
                    return DropdownMenuItem<String>(
                      value: category['label'],
                      child: Row(
                        children: [
                          Icon(category['icon'], size: 20,),
                          SizedBox(width: 10,),
                          Text(category['label']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value){
                    selectedCategory = value;
                  },
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                    onPressed: () async {
                      if (titleController.text.isNotEmpty &&
                          amountController.text.isNotEmpty &&
                          selectedCategory != null) {
                        double amount = double.parse(amountController.text);
                        double newBalance = await _firestoreService.calculateNewBalance(amount, 'income', selectedPaymentMethod);
                        await _firestoreService.addTransaction({
                          'title': titleController.text,
                          'amount': double.parse(amountController.text),
                          'date': DateTime.now(),
                          'type': 'income',
                          'category': selectedCategory,
                          'paymentMethod': selectedPaymentMethod,
                          'balance': newBalance
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Add Income",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        );
      }
  );
}