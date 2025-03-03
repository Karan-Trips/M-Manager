import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

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
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
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
          msg: "Please enter a valid amount and select friends.",
          gravity: ToastGravity.BOTTOM);
      return;
    }

    double splitAmount = totalAmount / friendsCount;

    for (var contact in _selectedContacts) {
      _sendNotification(contact.displayName, "You owe ₹${splitAmount.toStringAsFixed(2)}");
    }
  }

  Future<void> _sendNotification(String title, String body) async {
    await _firebaseMessaging.subscribeToTopic("expense_notifications");
    Fluttertoast.showToast(
        msg: "Notification sent: $title - $body", gravity: ToastGravity.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Split Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset("images/moneysplit.json", height: 200.h),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Amount",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search Contacts",
                border: OutlineInputBorder(),
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
              label: const Text("Split & Notify"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
