import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:m_manager/ui/screen/home_page.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:m_manager/ui/screen/budget_page.dart';
import 'package:m_manager/ui/screen/manage_categories.dart';
import 'package:m_manager/firebase_store/expense_store.dart';
import 'package:m_manager/generated/l10n.dart';

import '../../auth/login_screen.dart';
import 'spiltter/recipet.dart';

/// 🎨 THEME COLORS
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationEnabled = false;

  /// ================= USER DATA =================

  Future<Map<String, String>> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return {
        "name": userDoc["name"] ?? "Unknown User",
        "email": user.email ?? "No Email",
      };
    }
    return {"name": "Guest", "email": "Not Logged In"};
  }

  /// ================= RECEIPT =================

  Future<void> generateAndSaveReceipt() async {
    try {
      Uint8List receiptBytes = await ReceiptPDF.generateReceiptAsBytes(
        title: S.of(context).expenseReceipt,
        date: DateTime.now().toString(),
        expenses: expenseStore.expenses,
        totalAmount: expenseStore.totalExpenses,
      );

      Directory? directory;

      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
              msg: "Storage permission denied", backgroundColor: _red);
          return;
        }

        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return;

      final filePath =
          "${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf";

      File file = File(filePath);
      await file.writeAsBytes(receiptBytes);

      Fluttertoast.showToast(
        msg: "Receipt saved successfully",
        backgroundColor: _green,
      );

      OpenFile.open(filePath);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to generate receipt",
        backgroundColor: _red,
      );
    }
  }

  /// ================= LANGUAGE =================

  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    Fluttertoast.showToast(
      msg: "Language changed",
      backgroundColor: _purple,
    );
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Text(
          S.of(context).settings,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserCard(),
              SizedBox(height: 28.h),
              SectionHeader(title: "General"),
              SizedBox(height: 10.h),
              _buildSectionCard(children: [
                _buildTile(
                  icon: Icons.receipt_long,
                  title: S.of(context).printReceipt,
                  onTap: generateAndSaveReceipt,
                ),
                _divider(),
                _buildTile(
                  icon: Icons.category,
                  title: S.of(context).manageCategories,
                  onTap: () => Get.to(() => ManageCategoriesPage()),
                ),
                _divider(),
                _buildTile(
                  icon: Icons.pie_chart,
                  title: S.of(context).setBudget,
                  onTap: () => Get.to(() => SetBudgetPage()),
                ),
              ]),
              SizedBox(height: 24.h),
              SectionHeader(title: "Preferences"),
              SizedBox(height: 10.h),
              _buildSectionCard(children: [
                _buildNotificationTile(),
                _divider(),
                _buildTile(
                  icon: Icons.language,
                  title: "Change Language",
                  onTap: () => _showLanguageSelectionDialog(context),
                ),
              ]),
              SizedBox(height: 24.h),
              _buildSectionCard(children: [
                _buildTile(
                  icon: Icons.logout,
                  title: S.of(context).logout,
                  iconColor: _red,
                  textColor: _red,
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Get.offAll(() => LoginPage());
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= WIDGETS =================

  Widget _buildUserCard() {
    return FutureBuilder<Map<String, String>>(
      future: getUserDetails(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_purple, _purpleLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor: Colors.white,
                child: Text(
                  userData["name"]![0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: _purple,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData["name"]!,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    userData["email"]!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.r),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _purpleSoft,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: iconColor ?? _purple, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 0.6, color: Colors.grey.shade200);

  Widget _buildNotificationTile() {
    return SwitchListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 18.w),
      secondary: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _purpleSoft,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.notifications, color: _purple, size: 20.sp),
      ),
      title: Text(S.of(context).notifications),
      activeColor: _purple,
      value: isNotificationEnabled,
      onChanged: (value) {
        setState(() => isNotificationEnabled = value);
      },
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption("English", "en"),
              SizedBox(height: 12.h),
              _languageOption("हिन्दी", "hi"),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(String title, String code) {
    return InkWell(
      onTap: () {
        changeLanguage(Locale(code));
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _purpleSoft,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _purple,
          ),
        ),
      ),
    );
  }
}
