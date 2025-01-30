// // ignore_for_file: use_build_context_synchronously, avoid_print

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:try1/Widgets_screen/loading_screen.dart';
import 'package:try1/auth/getx_auth/getx_login.dart';
import 'package:try1/auth/reset_password.dart';

import 'package:try1/auth/sign_up_page.dart';
import 'package:try1/utils/design_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);

  Widget _entryField(
      String title, bool isPassword, TextEditingController? controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.spMax),
          ),
          SizedBox(height: 10.h),
          ValueListenableBuilder(
            valueListenable: _isPasswordVisible,
            builder: (context, value, child) => TextFormField(
              style: TextStyle(
                color: Colors.red[900],
              ),
              controller: controller,
              obscureText: isPassword && !_isPasswordVisible.value,
              decoration: InputDecoration(
                hintText:
                    isPassword ? 'Enter your password' : 'Enter your email',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15.spMax),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0.r),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _isPasswordVisible.value = !_isPasswordVisible.value;
                        },
                      )
                    : const SizedBox.shrink(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                fillColor: const Color(0xfff3f3f4),
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 18.h, horizontal: 23.w),
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
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
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignUpPage()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
          text: 'M',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xffe46b10)),
          children: [
            TextSpan(
              text: '-',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'Manger',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Email id", false, loginController.emailController),
        _entryField("Password", true, loginController.passwordController),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Obx(() {
        return Loading(
          status: loginController.isLoading.value,
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -height * .15,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: const BezierContainer(),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: height * .2),
                          _title(),
                          SizedBox(height: 50.h),
                          _emailPasswordWidget(),
                          SizedBox(height: 20.h),
                          _submitButton('Login', () async {
                            bool isValid =
                                await loginController.validate(context);
                            if (isValid) {
                              return loginController.login(context);
                            }
                          }),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ResetPasswordScreen()));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot Password ?',
                                style: TextStyle(
                                  fontSize: 14.spMax,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          _divider(),
                          _createAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
