// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:theme_provider/theme_provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late TextEditingController _amountController;
  late TextEditingController _incomeController;
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  String _selectedCategory = 'Groceries';
  bool isDarkMode = false;
  bool showIncomeTextField = false;
  late double currentIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _incomeController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _incomeController.dispose();
  }

  Future<void> saveExpenseData(double amount, String category) async {
    try {
      var id = Random().nextInt(1000);
      var currentDate = getCurrentDate();
      var currentTime = getCurrentTime();

      CollectionReference expenses =
          FirebaseFirestore.instance.collection('expenses');
      double incomeValue = double.tryParse(_incomeController.text) ?? 0.0;
      await expenses.add({
        'id': id,
        'date': currentDate,
        'time': currentTime,
        'amount': amount,
        'income': incomeValue,
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

  void updateIncomeValue() async {
    try {
      double newIncomeValue = double.tryParse(_incomeController.text) ?? 0.0;
      CollectionReference incomes =
          FirebaseFirestore.instance.collection('incomes');

      DocumentReference incomeDocument = incomes.doc('income_document');

      // Check if the document exists before updating
      DocumentSnapshot documentSnapshot = await incomeDocument.get();

      if (documentSnapshot.exists) {
        await incomeDocument.update({
          'income': newIncomeValue,
          // Add any additional fields you may have in your income document
        });
      } else {
        createIncomeDocument(newIncomeValue);
      }
      _incomeController.clear();
      print("Income value updated successfully: $newIncomeValue");
    } catch (error) {
      print("Failed to update income value: $error");
    }
  }

  void createIncomeDocument(double newIncomeValue) async {
    try {
      CollectionReference incomes =
          FirebaseFirestore.instance.collection('incomes');
      DocumentReference incomeDocument = incomes.doc('income_document');
      _incomeController.clear();
      await incomeDocument.set({
        'income': newIncomeValue,
      });

      print("Income document created successfully with value: $newIncomeValue");
    } catch (error) {
      print("Failed to create income document: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode =
        ThemeProvider.themeOf(context).data.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        centerTitle: true,
        backgroundColor:
            ThemeProvider.themeOf(context).data.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Amount:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Form(
                key: _formkey,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Enter your Amount',
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter an amount';
                    } else if (value.length > 8) {
                      return 'Amount is too large to handle';
                    }
                    double? amount = double.tryParse(value);
                    if (amount != null && amount < 0) {
                      return 'Amount cannot be below zero or zero';
                    }
                    return null;
                  },
                ),
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
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        style: TextStyle(
                            fontSize: 16.0,
                            color: isDarkMode ? Colors.white : Colors.black),
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
                      showToast("Invalid input for amount");
                      return;
                    }
                    if (_formkey.currentState?.validate() ?? false) {
                      saveExpenseData(parsedAmount, category);
                      showToast("Transaction Saved !");
                      Navigator.pop(context);
                    } else {
                      showToast("Please fill all fields");
                    }
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
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 60,
                width: 250,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        showIncomeTextField = !showIncomeTextField;
                      });
                    },
                    child: const Text("Add Income")),
              ),
              if (showIncomeTextField)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Income:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Form(
                      key: _formkey2,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Enter the Income",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        controller: _incomeController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter an Income';
                          } else if (value.length > 8) {
                            return 'Amount is too large to handle';
                          }
                          double? amount = double.tryParse(value);
                          if (amount != null && amount < 0) {
                            return 'Amount cannot be below zero';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            side:
                                const BorderSide(width: 3, color: Colors.brown),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.all(20)),
                        onPressed: () {
                          if (_formkey2.currentState?.validate() ?? false) {
                            updateIncomeValue();
                            print("saved");
                            Navigator.pop(context);
                          } else {
                            showToast("Enter  valid income");
                          }

                          setState(() {});
                        },
                        child: const Icon(Icons.account_balance_wallet_rounded))
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
