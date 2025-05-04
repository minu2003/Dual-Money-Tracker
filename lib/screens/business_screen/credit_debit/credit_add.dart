import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/firestore_services.dart';
import '../../../Provider/paymentMethod_provider.dart';

final FirestoreService _firestoreService = FirestoreService();

void AddCreditDialog (BuildContext context){
  String? selectedCategory;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isRecurring = false;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.account_balance, "label": "Sales Revenue"},
    {"icon": Icons.monetization_on, "label": "Loans"},
    {"icon": Icons.savings, "label": "Investments"},
    {"icon": Icons.savings, "label": "Refunds"},
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
                  cursorColor: Colors.blue,
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                        fontSize: 14
                    ),
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Change to blue
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  cursorColor: Colors.blue,
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                        fontSize: 14
                    ),
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Change to blue
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Change to blue
                    ),
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
                SwitchListTile(
                    title: Text("Recurring"),
                    value: isRecurring,
                    onChanged: (bool value){
                      isRecurring = value;
                      (context as Element).markNeedsBuild();
                    }
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
                        double newBalance = await _firestoreService.calculateNewBalance(amount, 'income', selectedPaymentMethod, isBusiness: true);
                        await _firestoreService.addBusinessCredit({
                          'title': titleController.text,
                          'amount': double.parse(amountController.text),
                          'date': DateTime.now(),
                          'type': 'credit',
                          'category': selectedCategory,
                          'paymentMethod': selectedPaymentMethod,
                          'balance': newBalance,
                          'isRecurring': isRecurring,
                          'recurringFrequency': isRecurring ? 'monthly' : null,
                        },
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Add Credit",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        );
      }
  );
}