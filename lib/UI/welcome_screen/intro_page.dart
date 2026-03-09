// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:m_manager/app_db.dart';
import 'package:m_manager/auth/login_screen.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);

const _bg = Color(0xFFF5F3FF);

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    {
      "title": "Split & Share",
      "description":
          "Split bills with friends and family. Keep track of who owes what.",
      "imagePath": "images/moneysplit.json",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _onNextPressed() {
    if (_currentPage < _introData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      appDb.isFirstTime = false;
      Get.off(
        () => LoginPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  void _onSkipPressed() {
    appDb.isFirstTime = false;
    Get.off(
      () => LoginPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: _purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _introData.length,
                itemBuilder: (context, index) {
                  return _buildIntroPage(_introData[index]);
                },
              ),
            ),

            // Page Indicators and Navigation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _introData.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Navigation Buttons
                  Row(
                    children: [
                      // Back Button (if not first page)
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _purple,
                              side: BorderSide(color: _purple, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_currentPage > 0) SizedBox(width: 16.w),

                      // Next/Get Started Button
                      Expanded(
                        flex: _currentPage > 0 ? 1 : 2,
                        child: _buildNextButton(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage(Map<String, String> data) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Container(
              height: 200.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _purple.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Lottie.asset(
                  data["imagePath"]!,
                  height: 220.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 60.h),

            // Title with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [_purple, _purpleLight],
              ).createShader(bounds),
              child: Text(
                data["title"]!,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.h),

            // Description
            Text(
              data["description"]!,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.6,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isActive ? 32.w : 8.w,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [_purple, _purpleLight],
              )
            : null,
        color: isActive ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = _currentPage == _introData.length - 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_purple, _purpleLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? 'Get Started' : 'Next',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isLastPage ? Icons.rocket_launch : Icons.arrow_forward,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
