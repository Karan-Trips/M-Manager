// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:m_manager/ui/cubits_app/cubits_app.dart';
import 'package:m_manager/ui/cubits_app/cubits_state.dart';
import 'package:m_manager/widgets_screen/ai/ai_page_learning.dart';
import 'package:m_manager/widgets_screen/loading_screen.dart';

import '../../generated/l10n.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddExpenseCubit, AddExpenseState>(
      listener: (context, state) {
        if (state is ExpenseSuccess) {
          Fluttertoast.showToast(
            msg: state.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Get.back();
        } else if (state is ExpenseFailure) {
          Fluttertoast.showToast(
            msg: state.error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.watch<AddExpenseCubit>();
        final isDarkMode =
            ThemeProvider.themeOf(context).data.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDarkMode ? null : _bg,
          appBar: AppBar(
            elevation: 0,
            title: Text(
              S.of(context).addExpense,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: isDarkMode
                ? ThemeProvider.themeOf(context)
                    .data
                    .appBarTheme
                    .backgroundColor
                : _purple,
            foregroundColor: Colors.white,
          ),
          body: state is ExpenseLoading
              ? const Loading(status: true)
              : _buildBody(context, cubit, isDarkMode, isIOS: Platform.isIOS),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, AddExpenseCubit cubit, bool isDarkMode,
      {required bool isIOS}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Amount Card
          _buildCard(
            isDarkMode: isDarkMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  icon: Icons.payments_outlined,
                  title: S.of(context).amount,
                  isDarkMode: isDarkMode,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: cubit.amountController,
                  hintText: S.of(context).enterYourAmount,
                  keyboardType: TextInputType.number,
                  validator: cubit.validateAmount,
                  isDarkMode: isDarkMode,
                  isIOS: isIOS,
                  prefixIcon: Icons.attach_money,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Category Card
          _buildCard(
            isDarkMode: isDarkMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  icon: Icons.category_outlined,
                  title: S.of(context).category,
                  isDarkMode: isDarkMode,
                ),
                SizedBox(height: 12.h),
                _buildDropdown(context, isDarkMode, isIOS),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Save Button
          _buildPrimaryButton(
            onPressed: cubit.saveExpense,
            text: S.of(context).saveExpense,
            icon: Icons.save_outlined,
            color: Colors.green,
            isIOS: isIOS,
          ),
          SizedBox(height: 12.h),

          // Add Income Button
          _buildSecondaryButton(
            onPressed: cubit.toggleIncomeField,
            text: S.of(context).addIncome,
            icon: Icons.add_circle_outline,
            isIOS: isIOS,
            isDarkMode: isDarkMode,
          ),

          // Income Section (Expandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: cubit.showIncomeTextField
                ? Column(
                    children: [
                      SizedBox(height: 16.h),
                      _buildCard(
                        isDarkMode: isDarkMode,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.account_balance_wallet_outlined,
                              title: S.of(context).income,
                              isDarkMode: isDarkMode,
                            ),
                            SizedBox(height: 12.h),
                            _buildTextField(
                              controller: cubit.incomeController,
                              hintText: S.of(context).enterTheIncome,
                              keyboardType: TextInputType.number,
                              validator: cubit.validateIncome,
                              isDarkMode: isDarkMode,
                              isIOS: isIOS,
                              prefixIcon: Icons.trending_up,
                            ),
                            SizedBox(height: 16.h),
                            Center(
                              child: _buildIconButton(
                                cubit.updateIncome,
                                isIOS,
                                isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(height: 24.h),

          // Scan Receipt Button (Development)
          _buildOutlinedButton(
            onPressed: () {
              Fluttertoast.showToast(
                msg: S.of(context).underDevelopment,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.orange,
                textColor: Colors.white,
                fontSize: 16.sp,
              );
              Get.to(() => ReceiptPage());
            },
            text: "Scan Receipt",
            icon: Icons.document_scanner_outlined,
            isIOS: isIOS,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildCard({
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: _purpleSoft,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: _purple,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    required bool isDarkMode,
    required bool isIOS,
    IconData? prefixIcon,
  }) {
    return isIOS
        ? CupertinoTextField(
            controller: controller,
            placeholder: hintText,
            keyboardType: keyboardType,
            padding: EdgeInsets.all(16.r),
            prefix: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Icon(
                      prefixIcon,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                  )
                : null,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
          )
        : TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 15.sp,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: _purple,
                      size: 22.sp,
                    )
                  : null,
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: _purple,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
          );
  }

  Widget _buildDropdown(BuildContext context, bool isDarkMode, bool isIOS) {
    return BlocBuilder<AddExpenseCubit, AddExpenseState>(
      builder: (context, state) {
        final cubit = context.watch<AddExpenseCubit>();
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButton2<String>(
            underline: Container(),
            isExpanded: true,
            value: cubit.categories.contains(cubit.selectedCategory)
                ? cubit.selectedCategory
                : cubit.categories.first,
            onChanged: (value) {
              cubit.updateCategory(value);
            },
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _purple,
              ),
              iconSize: 24.sp,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              maxHeight: 300.h,
            ),
            buttonStyleData: ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              height: 56.h,
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            items: cubit.categories
                .map<DropdownMenuItem<String>>(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
    required bool isIOS,
  }) {
    return isIOS
        ? CupertinoButton(
            borderRadius: BorderRadius.circular(12.r),
            color: color,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            height: 56.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: color.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isIOS,
    required bool isDarkMode,
  }) {
    return isIOS
        ? CupertinoButton(
            borderRadius: BorderRadius.circular(12.r),
            color: isDarkMode ? Colors.grey[800] : _purpleSoft,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: _purple,
                ),
                SizedBox(width: 8.w),
                Text(
                  text,
                  style: TextStyle(
                    color: _purple,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            height: 56.h,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: BorderSide(color: _purple, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isIOS,
    required bool isDarkMode,
  }) {
    return isIOS
        ? CupertinoButton(
            borderRadius: BorderRadius.circular(12.r),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: _purpleLight,
                ),
                SizedBox(width: 8.w),
                Text(
                  text,
                  style: TextStyle(
                    color: _purpleLight,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            height: 56.h,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20.sp),
              label: Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purpleLight,
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[700]!
                      : _purpleLight.withOpacity(0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
  }

  Widget _buildIconButton(VoidCallback onPressed, bool isIOS, bool isDarkMode) {
    return isIOS
        ? CupertinoButton(
            onPressed: onPressed,
            padding: EdgeInsets.all(12.r),
            color: _purpleSoft,
            borderRadius: BorderRadius.circular(12.r),
            child: Icon(
              CupertinoIcons.money_dollar_circle,
              color: _purple,
              size: 28.sp,
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(16.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Update Income",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
  }
}
