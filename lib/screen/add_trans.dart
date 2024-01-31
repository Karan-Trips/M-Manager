// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theme_provider/theme_provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late TextEditingController _amountController;
  String _selectedCategory = 'Groceries';

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> saveExpenseData(double amount, String category) async {
    try {
      var id = Random().nextInt(1000);
      var currentDate = getCurrentDate();
      var currentTime = getCurrentTime();

      CollectionReference expenses =
          FirebaseFirestore.instance.collection('expenses');

      await expenses.add({
        'id': id,
        'date': currentDate,
        'time': currentTime,
        'amount': amount,
        'category': category,
      });

      print("Expense added");
    } catch (error) {
      print("Failed to add expense: $error");
    }
  }

  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  String getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        centerTitle: true,
        backgroundColor:
            ThemeProvider.themeOf(context).data.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Amount:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)))),
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text(
              'Category:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.category_outlined, color: Colors.blue),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: const [
                        'Groceries',
                        'Fast-Food',
                        'Ghumne',
                        'Food',
                        'Medicine',
                        'Office',
                        'Other',
                      ]
                          .map<DropdownMenuItem<String>>(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.black),
                      underline: Container(),
                      isExpanded: true,
                      hint: const Text(
                        'Select a category',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  String amountText = _amountController.text;
                  String category = _selectedCategory;
                  double? parsedAmount;

                  try {
                    parsedAmount = double.parse(amountText);
                  } catch (e) {
                    dialogbox(context);
                    return;
                  }
                  saveExpenseData(parsedAmount, category);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Expense',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dialogbox(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a valid amount.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
