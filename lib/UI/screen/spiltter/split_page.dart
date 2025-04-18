import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';

class SplitExpensePage extends StatefulWidget {
  const SplitExpensePage({super.key});

  @override
  State<SplitExpensePage> createState() => _SplitExpensePageState();
}

class _SplitExpensePageState extends State<SplitExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  final List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _contacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _splitAndNotify() {
    double? totalAmount = double.tryParse(_amountController.text);
    int friendsCount = _selectedContacts.length;

    if (totalAmount == null || friendsCount == 0) {
      Fluttertoast.showToast(
          msg: S.of(context).pleaseEnterAValidAmountAndSelectFriends,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    double splitAmount = totalAmount / friendsCount;

    for (var contact in _selectedContacts) {
      _sendNotification(
          contact.displayName, "You owe ₹${splitAmount.toStringAsFixed(2)}");
    }
  }

  Future<void> _sendNotification(String title, String body) async {
    await _firebaseMessaging.subscribeToTopic("expense_notifications");
    Fluttertoast.showToast(
        msg: "Notification sent: $title - $body", gravity: ToastGravity.CENTER);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).splitExpense)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset("images/moneysplit.json", height: 200.h),
            _buildTextField(
              controller: _amountController,
              hintText: S.of(context).enterTotalAmount,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).pleaseEnterAValidAmount;
                }
                return null;
              },
              isDarkMode: false,
              isIOS: false,
            ),
            SizedBox(height: 15.h),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: S.of(context).searchContacts,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.r)),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterContacts,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  Contact contact = _filteredContacts[index];
                  bool isSelected = _selectedContacts.contains(contact);
                  return ListTile(
                    title: Text(contact.displayName),
                    leading: Icon(isSelected
                        ? Icons.check_circle
                        : Icons.circle_outlined),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedContacts.remove(contact);
                        } else {
                          _selectedContacts.add(contact);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _splitAndNotify,
              icon: const Icon(Icons.send),
              label: Text(S.of(context).splitNotify),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
