// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:try1/app_db.dart';
import 'package:try1/firebase_store/expense_store.dart';
import 'package:try1/main.dart';
import 'package:try1/utils/utils.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  Future<bool> validate(BuildContext context) async {
    if (loginController.emailController.text.isEmpty) {
      showMessageTop(context, "Enter Email Address");
      return false;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(loginController.emailController.text)) {
      showMessageTop(context, "Enter a valid email address.");
      return false;
    }

    if (loginController.passwordController.text.isEmpty) {
      showMessageTop(context, "Enter your password.");
      return false;
    }

    if (loginController.passwordController.text.length < 6) {
      showMessageTop(context, "Password must be at least 6 characters long.");
      return false;
    }

    return true;
  }

  Future<void> login(BuildContext context) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: loginController.emailController.text.trim(),
        password: loginController.passwordController.text.trim(),
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
}

final LoginController loginController = Get.put(LoginController());
