// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:lottie/lottie.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:try1/app_db.dart';
import 'package:try1/auth/login_screen.dart';

import 'package:try1/main.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

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
    if (_currentPage.value < _introData.length - 1) {
      setState(() {
        _currentPage.value++;
      });
      print(_currentPage.value);
    } else {
      appDb.isFirstTime = false;
      Get.off(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final intro = _introData[_currentPage.value];

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
              SizedBox(height: 30.h),
              Text(
                intro["title"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                intro["description"]!,
                style: TextStyle(
                  fontSize: 16.spMin,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              ValueListenableBuilder(
                  valueListenable: _currentPage,
                  builder: (context, val, child) {
                    return GestureDetector(
                      onTap: _onNextPressed,
                      child: CircularStepProgressIndicator(
                        totalSteps: 2,
                        currentStep: val + 1,
                        width: 100,
                        selectedColor: Colors.amber,
                        roundedCap: (_, isSelected) {
                          return isSelected;
                        },
                        child: Icon(Icons.arrow_forward),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
