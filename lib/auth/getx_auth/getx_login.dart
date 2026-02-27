// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m_manager/app_db.dart';
import 'package:m_manager/firebase_store/expense_store.dart';
import 'package:m_manager/ui/screen/home_page.dart';
import 'package:m_manager/utils/utils.dart';
import 'package:m_manager/widgets_screen/show_message.dart';

import '../../generated/l10n.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  Future<bool> validate(BuildContext context) async {
    if (loginController.emailController.text.isEmpty) {
      showMessageTop(context, S.of(context).enterEmailAddress);
      return false;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(loginController.emailController.text)) {
      showMessageTop(context, S.of(context).enterAValidEmailAddress);
      return false;
    }

    if (loginController.passwordController.text.isEmpty) {
      showMessageTop(context, S.of(context).enterYourPassword);
      return false;
    }

    if (loginController.passwordController.text.length < 6) {
      showMessageTop(
          context, S.of(context).passwordMustBeAtLeast6CharactersLong);
      return false;
    }

    return true;
  }

  Future<void> login() async {
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
            debugPrint("User is null or UID is empty.");
          }
          isLoading.value = false;
          Get.off(() => MoneyManagerHomePage());
        },
      );
    } catch (error) {
      isLoading.value = false;
      debugPrint('Login failed: $error');
      showMessage('Login failed:$error', type: MessageType.error);
    }
  }
}

final LoginController loginController = Get.put(LoginController());
