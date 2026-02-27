import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:m_manager/widgets_screen/loading_screen.dart';
import 'package:m_manager/auth/getx_auth/getx_sign_up.dart';
import 'package:m_manager/utils/design_container.dart';

import '../generated/l10n.dart';
import 'login_screen.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Loading(
          status: signUpController.isLoading.value,
          child: Form(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -MediaQuery.of(context).size.height * .15,
                    right: -MediaQuery.of(context).size.width * .4,
                    child: const BezierContainer(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              height: MediaQuery.of(context).size.height * .2),
                          _title(),
                          const SizedBox(height: 50),
                          _emailPasswordWidget(signUpController),
                          const SizedBox(height: 20),
                          _submitButton(signUpController, context),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * .14),
                          _loginAccountLabel(context),
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
              text: '-', style: TextStyle(color: Colors.black, fontSize: 30)),
          TextSpan(
              text: 'Manger',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30)),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget(SignUpController signUpController) {
    return Column(
      children: <Widget>[
        _entryField("Username", false, signUpController.usernameController),
        _entryField("Email id", false, signUpController.emailController),
        _entryField("Password", true, signUpController.passwordController),
      ],
    );
  }

  Widget _entryField(
      String title, bool isPassword, TextEditingController signUpController) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15.spMax)),
          SizedBox(height: 10.h),
          TextFormField(
            style: TextStyle(color: Colors.red[900]),
            controller: signUpController,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
              ),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(SignUpController signUpController, context) {
    return InkWell(
      onTap: () {
        signUpController.signUp(context);
      },
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
          S.of(context).registerNow,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => LoginPage());
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(S.of(context).alreadyHaveAnAccount,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            SizedBox(width: 10),
            Text(S.of(context).login,
                style: TextStyle(
                    color: Color(0xfff79c4f),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
