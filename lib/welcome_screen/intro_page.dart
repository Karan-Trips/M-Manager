// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:try1/main.dart';

import '../firebase_store/expense_store.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _currentPage = 0;

  final List<Map<String, String>> _introData = [
    {
      "title": "Track Your Expenses",
      "description":
          "Monitor where your money goes with easy-to-read charts and detailed reports.",
      "imagePath": "images/intro1.json",
    },
    {
      "title": "Set Budgets and Save",
      "description":
          "Define your monthly budgets and achieve your saving goals effortlessly.",
      "imagePath": "images/into2.json",
    },
  ];

  void _onNextPressed() {
    if (_currentPage < _introData.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      // Navigate or initialize the app
      final expenseStore = ExpenseStore();
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyMoneyManagerApp(
            expenseStore: expenseStore,
            user: user,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final intro = _introData[_currentPage];

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                intro["imagePath"]!,
                height: 250.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              Text(
                intro["title"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                intro["description"]!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _onNextPressed,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _currentPage < _introData.length - 1 ? "Next" : "Get Started",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
