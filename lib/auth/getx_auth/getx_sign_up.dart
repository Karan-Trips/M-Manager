// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:try1/utils/utils.dart';

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
      print("asdasd_)___");
      showMessageTop(context, 'Enter the UserName');
      return false;
    } else if (_emailController.text.isEmpty) {
      showMessageTop(context, 'Enter Email Address');

      return false;
    } else if (_passwordController.text.isEmpty) {
      showMessageTop(context, 'Enter your password.');

      return false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(_emailController.text)) {
      showMessageTop(context, 'Enter a valid email address.');

      return false;
    }
    return true;
  }

  Future<void> signUp(BuildContext context) async {
    print("adsasd-----");
    if (await validateForm(context)) {
      isLoading.value = true;
      try {
        print("asdasdasdasd");
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
        // Navigator.of(context).pop();
        Get.back();
      } catch (error) {
        isLoading.value = false;
        showMessageTop(context, 'Signup failed ${error.toString()}');
      }
    }
  }
}

final SignUpController signUpController = Get.put(SignUpController());
