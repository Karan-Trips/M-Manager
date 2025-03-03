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
import 'package:try1/UI/cubits_app/cubits_app.dart';
import 'package:try1/UI/cubits_app/cubits_state.dart';
import 'package:try1/widgets_screen/ai/ai_page_learning.dart';
import 'package:try1/widgets_screen/loading_screen.dart';


class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddExpenseCubit(),
      child: BlocConsumer<AddExpenseCubit, AddExpenseState>(
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
            // Navigator.pop(context);
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
          final cubit = context.read<AddExpenseCubit>();
          final isDarkMode =
              ThemeProvider.themeOf(context).data.brightness == Brightness.dark;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Add Expense'),
              centerTitle: true,
              backgroundColor: ThemeProvider.themeOf(context)
                  .data
                  .appBarTheme
                  .backgroundColor,
            ),
            body: state is ExpenseLoading
                ? const Loading(status: true)
                : _buildBody(
                    context,
                    cubit,
                    isDarkMode,
                    isIOS: Platform.isIOS ? true : false,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AddExpenseCubit cubit, bool isDarkMode,
      {required bool isIOS}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildLabel('Amount:', isIOS),
          _buildTextField(
            controller: cubit.amountController,
            hintText: 'Enter your Amount',
            keyboardType: TextInputType.number,
            validator: cubit.validateAmount,
            isDarkMode: isDarkMode,
            isIOS: isIOS,
          ),
          SizedBox(height: 20.h),
          _buildLabel('Category:', isIOS),
          _buildDropdown(cubit, isDarkMode, isIOS),
          SizedBox(height: 20.h),
          _buildButton(
              onPressed: cubit.saveExpense, text: 'Save Expense', isIOS: isIOS),
          SizedBox(height: 20.h),
          _buildButton(
              onPressed: cubit.toggleIncomeField,
              text: 'Add Income',
              isIOS: isIOS),
          if (cubit.showIncomeTextField)
            Column(
              children: [
                SizedBox(height: 20.h),
                _buildLabel('Income:', isIOS),
                _buildTextField(
                    controller: cubit.incomeController,
                    hintText: 'Enter the Income',
                    keyboardType: TextInputType.number,
                    validator: cubit.validateIncome,
                    isDarkMode: isDarkMode,
                    isIOS: isIOS),
                const SizedBox(height: 20),
                _buildIconButton(cubit.updateIncome, isIOS),
              ],
            ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              Get.to(() => RecpitPage());
            },
            child: Text(
              "Scan the page",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isIOS) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.spMin,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    required bool isDarkMode,
    required bool isIOS,
  }) {
    return isIOS
        ? CupertinoTextField(
            controller: controller,
            placeholder: hintText,
            keyboardType: keyboardType,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12.r),
            ),
          )
        : TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20.r),
              labelText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
              ),
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
          );
  }

  Widget _buildDropdown(AddExpenseCubit cubit, bool isDarkMode, bool isIOS) {
    return
      
        Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 8.0.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0.r),
      ),
      child: DropdownButton2<String>(
        underline: Container(),
        isExpanded: true,
        value: cubit.selectedCategory,
        onChanged: cubit.updateCategory,
        items: cubit.categories
            .map<DropdownMenuItem<String>>(
              (value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildButton(
      {required VoidCallback onPressed,
      required String text,
      required bool isIOS}) {
    return isIOS
        ? CupertinoButton(
            borderRadius: BorderRadius.circular(15.r),
            color: Colors.redAccent,
            onPressed: onPressed,
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          )
        : SizedBox(
            height: 60,
            width: 250,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(text),
            ),
          );
  }

  Widget _buildIconButton(VoidCallback onPressed, bool isIOS) {
    return isIOS
        ? CupertinoButton(
            onPressed: onPressed,
            child: const Icon(CupertinoIcons.money_dollar_circle),
          )
        : ElevatedButton(
            onPressed: onPressed,
            child: const Icon(Icons.account_balance_wallet_rounded),
          );
  }
}
