import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:m_manager/widgets_screen/loading_screen.dart';
import 'package:m_manager/auth/getx_auth/getx_login.dart';
import 'package:m_manager/auth/reset_password.dart';
import 'package:m_manager/auth/sign_up_page.dart';
import 'package:m_manager/widgets_screen/show_message.dart';

import '../generated/l10n.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);

const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
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

  Widget _entryField(
    String title,
    String hint,
    IconData icon,
    bool isPassword,
    TextEditingController? controller,
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
                  return isPassword
                      ? 'Please enter password'
                      : 'Please enter email';
                }
                if (!isPassword && !GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(String title, Function()? onTap) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              title,
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
              "or",
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
              showMessage('Under Development');
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

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an account?',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: () {
              Get.to(
                () => SignUpPage(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Text(
              S.of(context).register,
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
                text: S.of(context).manger,
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
          'Manage your money smartly',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(
          S.of(context).emailId,
          S.of(context).enterYourEmail,
          Icons.email_outlined,
          false,
          loginController.emailController,
        ),
        _entryField(
          S.of(context).password,
          S.of(context).enterYourPassword,
          Icons.lock_outline,
          true,
          loginController.passwordController,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        return Loading(
          status: loginController.isLoading.value,
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
                        SizedBox(height: 60.h),
                        _title(),
                        SizedBox(height: 48.h),

                        // Welcome Text
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Sign in to continue',
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
                        _emailPasswordWidget(),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                () => ResetPasswordScreen(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                S.of(context).forgotPassword,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _purple,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Login Button
                        _submitButton(S.of(context).login, () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            bool isValid =
                                await loginController.validate(context);
                            if (isValid) {
                              return loginController.login();
                            }
                          }
                        }),

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

                        // Create Account Label
                        _createAccountLabel(),
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
