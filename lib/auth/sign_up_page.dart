import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:m_manager/widgets_screen/loading_screen.dart';
import 'package:m_manager/auth/getx_auth/getx_sign_up.dart';

import '../generated/l10n.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);

const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.title});
  final String? title;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _title() {
    return Column(
      children: [
        // Logo Container
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_purple, _purpleLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // App Name
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'M',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: _purple,
            ),
            children: [
              TextSpan(
                text: '-',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30.sp,
                ),
              ),
              TextSpan(
                text: 'Manager',
                style: TextStyle(
                  color: _purple,
                  fontSize: 30.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create your account',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _emailPasswordWidget(SignUpController signUpController) {
    return Column(
      children: <Widget>[
        _entryField(
          "Username",
          "Enter your username",
          Icons.person_outline,
          false,
          signUpController.usernameController,
        ),
        _entryField(
          "Email",
          "Enter your email",
          Icons.email_outlined,
          false,
          signUpController.emailController,
        ),
        _entryField(
          "Password",
          "Enter your password",
          Icons.lock_outline,
          true,
          signUpController.passwordController,
        ),
      ],
    );
  }

  Widget _entryField(
    String title,
    String hint,
    IconData icon,
    bool isPassword,
    TextEditingController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          ValueListenableBuilder(
            valueListenable: _isPasswordVisible,
            builder: (context, value, child) => TextFormField(
              controller: controller,
              obscureText: isPassword && !_isPasswordVisible.value,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15.sp,
                ),
                prefixIcon: Icon(icon, color: _purple, size: 22.sp),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _purple,
                          size: 22.sp,
                        ),
                        onPressed: () {
                          _isPasswordVisible.value = !_isPasswordVisible.value;
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 18.h,
                  horizontal: 20.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: _purple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: _red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: _red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${title.toLowerCase()}';
                }
                if (title == "Email" && !GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                if (title == "Password" && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                if (title == "Username" && value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(
      SignUpController signUpController, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_formKey.currentState?.validate() ?? false) {
              signUpController.signUp(context);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              S.of(context).registerNow,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "or sign up with",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              // Handle social signup
            },
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginAccountLabel(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            S.of(context).alreadyHaveAnAccount,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Text(
              S.of(context).login,
              style: TextStyle(
                color: _purple,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        return Loading(
          status: signUpController.isLoading.value,
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 40.h),
                        _title(),
                        SizedBox(height: 40.h),

                        // Create Account Text
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Sign up to get started',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Form Fields
                        _emailPasswordWidget(signUpController),
                        SizedBox(height: 8.h),

                        // Terms and Conditions
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'By signing up, you agree to our Terms of Service and Privacy Policy',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Sign Up Button
                        _submitButton(signUpController, context),

                        // Divider
                        _divider(),

                        // Social Login Buttons
                        Row(
                          children: [
                            _socialButton(
                              Icons.g_mobiledata,
                              'Google',
                              Colors.red,
                            ),
                            SizedBox(width: 16.w),
                            _socialButton(
                              Icons.facebook,
                              'Facebook',
                              Colors.blue,
                            ),
                            SizedBox(width: 16.w),
                            _socialButton(
                              Icons.apple,
                              'Apple',
                              Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // Login Label
                        _loginAccountLabel(context),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
