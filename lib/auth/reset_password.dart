// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:theme_provider/theme_provider.dart';
import 'package:try1/Widgets_screen/firebase_exceptions.dart';
import 'package:try1/utils/design_container.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'reset_password';
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  static final auth = FirebaseAuth.instance;
  static late AuthStatus _status;
  bool isDarkMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    await auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError(
            (e) => _status = AuthExceptionHandler.handleAuthException(e));

    return _status;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    isDarkMode =
        ThemeProvider.themeOf(context).data.brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 50.0, bottom: 25.0),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    // Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                  SizedBox(height: 70.h),
                  Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Please enter your email address to recover your password.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Email address',
                    style: TextStyle(
                      fontSize: 15.spMax,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    obscureText: false,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Empty email';
                      }
                      return null;
                    },
                    autofocus: false,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 20.w),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0.r))),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            30.0.r,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0.w),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            30.0.r,
                          ),
                        ),
                      ),

                      isDense: true,
                      // fillColor: kPrimaryColor,
                      filled: true,
                      errorStyle: TextStyle(fontSize: 15.spMin),
                      hintText: 'email address',
                      hintStyle: TextStyle(
                        fontSize: 17.spMin,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Expanded(child: SizedBox()),
                  _submitButton('Recover Password', () async {
                    if (_key.currentState!.validate()) {
                      final status = await resetPassword(
                          email: _emailController.text.trim());
                      if (status == AuthStatus.successful) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset email sent'),
                          ),
                        );
                        // Navigator.pop(context);
                        Get.back();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AuthExceptionHandler.generateErrorMessage(
                                    status)),
                          ),
                        );
                      }
                    }
                  }),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(String title, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.r)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          title,
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
      ),
    );
  }
}
