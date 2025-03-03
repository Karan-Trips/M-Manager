import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:try1/UI/screen/budget_page.dart';
import 'package:try1/UI/screen/manage_categories.dart';
import 'package:try1/UI/screen/spiltter/recipet.dart';
import 'package:try1/firebase_store/expense_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      // Generate PDF as bytes
      Uint8List receiptBytes = await ReceiptPDF.generateReceiptAsBytes(
        title: 'Expense Receipt',
        date: DateTime.now().toString(),
        expenses: expenseStore.expenses,
        totalAmount: expenseStore.totalExpenses,
      );

      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception("Failed to get storage directory");

      // Define file path
      String filePath = "${directory.path}/receipt.pdf";

      // Save the file
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
      appBar: AppBar(title: Text("Settings")),
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
                        backgroundColor: Colors.blueAccent,
                        child:
                            Icon(Icons.person, size: 30, color: Colors.white),
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
              title: Text("Print Receipt"),
              onTap: generateAndSaveReceipt,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Manage Categories"),
              onTap: () {
                Get.to(() => ManageCategoriesPage());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.pie_chart),
              title: Text("Set Budget"),
              onTap: () {
                Get.to(() => SetBudgetPage());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notifications"),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
