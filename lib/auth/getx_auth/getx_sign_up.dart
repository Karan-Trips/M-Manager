// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m_manager/utils/utils.dart';

import '../../generated/l10n.dart';

class SignUpController extends GetxController {
  var isLoading = false.obs;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  TextEditingController get usernameController => _usernameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  Future<bool> validateForm(BuildContext context) async {
    if (_usernameController.text.isEmpty) {
      debugPrint("asdasd_)___");
      showMessageTop(context, S.of(context).enterTheUsername);
      return false;
    } else if (_emailController.text.isEmpty) {
      showMessageTop(context, S.of(context).enterEmailAddress);

      return false;
    } else if (_passwordController.text.isEmpty) {
      showMessageTop(context, S.of(context).enterYourPassword);

      return false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(_emailController.text)) {
      showMessageTop(context, S.of(context).enterAValidEmailAddress);

      return false;
    }
    return true;
  }

  Future<void> signUp(BuildContext context) async {
    if (await validateForm(context)) {
      isLoading.value = true;
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(_usernameController.text.trim());
        _emailController.clear();
        _passwordController.clear();
        _usernameController.clear();
        isLoading.value = false;

        Get.back();
      } catch (error) {
        isLoading.value = false;
        showMessageTop(context, S.of(context).signupFailedErrortostring);
      }
    }
  }
}

final SignUpController signUpController = Get.put(SignUpController());
