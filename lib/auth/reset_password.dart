// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:theme_provider/theme_provider.dart';
import 'package:try1/auth/getx_auth/getx_login.dart';
import 'package:try1/widgets_screen/firebase_exceptions.dart';
import 'package:try1/utils/design_container.dart';
import 'package:try1/widgets_screen/loading_screen.dart';
import 'package:try1/widgets_screen/show_message.dart';

import '../generated/l10n.dart';

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
  bool isDarkMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    loginController.isLoading.value = true;

    try {
      await auth.sendPasswordResetEmail(email: email);
      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (_) {
      return AuthStatus.unknown;
    } finally {
      loginController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    isDarkMode =
        ThemeProvider.themeOf(context).data.brightness == Brightness.dark;
    return Scaffold(
      body: Loading(
        status: loginController.isLoading.value,
        child: Stack(
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
                      S.of(context).forgotPassword,
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      S
                          .of(context)
                          .pleaseEnterYourEmailAddressToRecoverYourPassword,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      S.of(context).emailAddress,
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
                          return S.of(context).emptyEmail;
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
                        hintText: S.of(context).emailAddress,
                        hintStyle: TextStyle(
                          fontSize: 17.spMin,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const Expanded(child: SizedBox()),
                    _submitButton(S.of(context).recoverPassword, () async {
                      if (_key.currentState!.validate()) {
                        final status = await resetPassword(
                            email: _emailController.text.trim());
                        if (status == AuthStatus.successful) {
                          showMessage(S.of(context).passwordResetEmailSent,
                              type: MessageType.success);

                          Get.back();
                        } else {
                          showMessage(
                            AuthExceptionHandler.generateErrorMessage(status),
                            type: MessageType.error,
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
