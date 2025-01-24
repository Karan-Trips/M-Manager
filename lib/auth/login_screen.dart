// // ignore_for_file: use_build_context_synchronously, avoid_print

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:try1/Widgets_screen/loading_screen.dart';
import 'package:try1/app_db.dart';
import 'package:try1/auth/reset_password.dart';

import 'package:try1/auth/sign_up_page.dart';
import 'package:try1/firebase_store/expense_store.dart';
import 'package:try1/main.dart';
import 'package:try1/utils/design_container.dart';
// import 'package:try1/utils/screen_utils.dart';

import '../utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final LocalAuthentication _localAuth = LocalAuthentication();

  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);
  Future<bool> validate() async {
    if (_emailController.text.isEmpty) {
      showMessageTop(context, "Enter Email Address");
      return false;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      showMessageTop(context, "Enter a valid email address.");
      return false;
    }

    if (_passwordController.text.isEmpty) {
      showMessageTop(context, "Enter your password.");
      return false;
    }

    if (_passwordController.text.length < 6) {
      showMessageTop(context, "Password must be at least 6 characters long.");
      return false;
    }

    return true;
  }

  Future<void> _login() async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .then(
        (value) async {
          var user = FirebaseAuth.instance.currentUser;
          if (user != null && user.uid.isNotEmpty) {
            appDb.isLogin = true;
            if (appDb.isFirstTime) {
              appDb.isFirstTime = false;
            }

            expenseStore.userId = user.uid;

            print(
                "User ID: !!!!!!!!!!!!!!!!! ! ${expenseStore.userId}@@@@@@@@@@@");

            DocumentReference userDoc =
                FirebaseFirestore.instance.collection('users').doc(user.uid);

            DocumentSnapshot docSnapshot = await userDoc.get();
            if (!docSnapshot.exists) {
              await userDoc.set(
                {
                  'uid': user.uid,
                  'email': user.email,
                  'name': user.displayName ?? 'Raju Don',
                  'expense': [],
                  'income': 0.0,
                  'created_at': FieldValue.serverTimestamp(),
                },
              );
            }

            await expenseStore.fetchExpenses();
            await expenseStore.fetchIncome();
          } else {
            print("User is null or UID is empty.");
          }
          isLoading.value = false;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyMoneyManagerApp(
                expenseStore: expenseStore,
                user: user,
              ),
            ),
          );
        },
      );
    } catch (error) {
      isLoading.value = false;
      print('Login failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    }
  }

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
        _entryField("Email id", false, _emailController),
        _entryField("Password", true, _passwordController),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, value, child) => Loading(
        status: value,
        child: Form(
          key: _formKey,
          child: SizedBox(
            height: height,
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: -height * .15,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: const BezierContainer()),
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
                          bool isValid = await validate();
                          if (isValid) {
                            return _login();
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
                        // GestureDetector(
                        //   onTap: () async {
                        //     // _loginWithBiometrics();
                        //   },
                        //   child: Image.asset(
                        //     'images/pngs/fingerprint.png',
                        //     scale: 3.h,
                        //   ).pV(20),
                        // ),
                        // const SizedBox(height: 20),
                        // _submitButton(
                        //     'SignUp',
                        //     () => Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (_) => const SignUpPage()))),
                        _createAccountLabel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  // Future<bool> _isBiometricAvailable() async {
  //   try {
  //     return await _localAuth.canCheckBiometrics ||
  //         await _localAuth.isDeviceSupported();
  //   } catch (e) {
  //     print("Error checking biometrics: $e");
  //     return false;
  //   }
  // }

  // Future<bool> _authenticateWithBiometrics() async {
  //   try {
  //     return await _localAuth.authenticate(
  //       localizedReason: 'Scan your fingerprint to log in',
  //       options: const AuthenticationOptions(biometricOnly: true),
  //     );
  //   } catch (e) {
  //     print("Error during biometric authentication: $e");
  //     return false;
  //   }
  // }

  // Future<void> _loginWithBiometrics() async {
  //   if (await _isBiometricAvailable()) {
  //     bool isAuthenticated = await _authenticateWithBiometrics();

  //     if (isAuthenticated) {
  //       isLoading.value = true;
  //       try {
  //         UserCredential userCredential = await _auth.signInAnonymously();
  //         User? user = userCredential.user;

  //         if (user != null) {
  //           print("Successfully logged in with UID: ${user.uid}");
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Login successful!')),
  //           );

  //           isLoading.value = false;
  //           Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(
  //               builder: (context) => MyMoneyManagerApp(
  //                 expenseStore: expenseStore,
  //                 user: user,
  //               ),
  //             ),
  //           );
  //         }
  //       } catch (e) {
  //         print("Error logging in: $e");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Firebase login failed')),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Authentication failed')),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Biometric authentication not available')),
  //     );
  //   }
  // }
}
