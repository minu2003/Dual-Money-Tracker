import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/firestore_services.dart';
import '../../../Provider/paymentMethod_provider.dart';

final FirestoreService _firestoreService = FirestoreService();

void AddDebitDialog (BuildContext context){
  String? selectedCategory;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isRecurring = false;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.house, "label": "Rent"},
    {"icon": Icons.monetization_on, "label": "Salaries and Wages"},
    {"icon": Icons.inventory, "label": "Supplies & Inventory"},
    {"icon": Icons.ads_click, "label": "Advertising/Marketing"},
    {"icon": Icons.money, "label": "Taxes & Fees"},
    {"icon": Icons.attach_money, "label": "Loan Repayments"},
    {"icon": Icons.directions_bus, "label": "Travel & Transportation"},
    {"icon": Icons.signal_wifi_statusbar_connected_no_internet_4_rounded, "label": "Internet & Communication"},
    {"icon": Icons.subscriptions, "label": "Software Subscriptions"},
    {"icon": Icons.category, "label": "Others"},
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
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                    onPressed: () async {
                      if (titleController.text.isNotEmpty &&
                          amountController.text.isNotEmpty &&
                          selectedCategory != null) {

                        double amount = double.parse(amountController.text);
                        double newBalance = await _firestoreService.calculateNewBalance(amount, 'expense', selectedPaymentMethod, isBusiness: true);

                        await _firestoreService.addBusinessCredit({
                          'title': titleController.text,
                          'amount': -double.parse(amountController.text),
                          'date': DateTime.now(),
                          'type': 'Debit',
                          'category': selectedCategory,
                          'paymentMethod': selectedPaymentMethod,
                          'balance' : newBalance,
                          'isRecurring': isRecurring,
                          'recurringFrequency': isRecurring ? 'monthly' : null,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Add Debit",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        );
      }
  );
}