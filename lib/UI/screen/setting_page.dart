import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:try1/UI/screen/budget_page.dart';
import 'package:try1/UI/screen/manage_categories.dart';
import 'package:try1/UI/screen/spiltter/recipet.dart';
import 'package:try1/firebase_store/expense_store.dart';
import 'package:try1/generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationEnabled = false;

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

  Future<void> generateAndSaveReceipt() async {
    try {
      Uint8List receiptBytes = await ReceiptPDF.generateReceiptAsBytes(
        title: S.of(context).expenseReceipt,
        date: DateTime.now().toString(),
        expenses: expenseStore.expenses,
        totalAmount: expenseStore.totalExpenses,
      );

      Directory? directory = await getExternalStorageDirectory();
      if (directory == null)
        throw Exception(S.of(context).failedToGetStorageDirectory);

      String filePath = "${directory.path}/receipt.pdf";

      File file = File(filePath);
      await file.writeAsBytes(receiptBytes);

      Fluttertoast.showToast(
        msg: 'Receipt saved successfully at $filePath',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      OpenFile.open(filePath);
    } catch (e) {
      print('$e');
      Fluttertoast.showToast(
        msg: 'Failed to generate receipt: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, String>>(
              future: getUserDetails(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var userData = snapshot.data!;
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.redAccent,
                        child: Text(userData["name"]![0],
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userData["name"]!,
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text(userData["email"]!,
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text(S.of(context).printReceipt),
              onTap: generateAndSaveReceipt,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text(S.of(context).manageCategories),
              onTap: () {
                Get.to(() => ManageCategoriesPage());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.pie_chart),
              title: Text(S.of(context).setBudget),
              onTap: () {
                Get.to(() => SetBudgetPage());
              },
            ),
            Divider(),
            _buildNotificationTile(),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(S.of(context).logout),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile() {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoListTile(
            leading: Icon(CupertinoIcons.bell),
            title: Text(S.of(context).notifications,
                style: TextStyle(color: Colors.white)),
            trailing: CupertinoSwitch(
              value: isNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  isNotificationEnabled = value;
                });
              },
            ),
          )
        : SwitchListTile(
            secondary: Icon(Icons.notifications),
            title: Text(S.of(context).notifications),
            value: isNotificationEnabled,
            onChanged: (value) {
              setState(() {
                isNotificationEnabled = value;
              });
            },
          );
  }
}
