import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class PersonExpense {
  final Contact contact;
  final List<ExpenseItem> expenses;

  PersonExpense({required this.contact, this.expenses = const []});

  double get totalAmount =>
      expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  PersonExpense copyWith({List<ExpenseItem>? expenses}) {
    return PersonExpense(
      contact: contact,
      expenses: expenses ?? this.expenses,
    );
  }
}

class ExpenseItem {
  final String description;
  final double amount;
  final DateTime date;

  ExpenseItem({
    required this.description,
    required this.amount,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

class SplitExpensePage extends StatefulWidget {
  const SplitExpensePage({super.key});

  @override
  State<SplitExpensePage> createState() => _SplitExpensePageState();
}

class _SplitExpensePageState extends State<SplitExpensePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  final List<PersonExpense> _selectedPeople = [];
  bool _isLoadingContacts = false;
  int _currentStep = 0; // 0: Select People, 1: Add Expenses, 2: Review & Send
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _selectedPeople.length, vsync: this);
    _getContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getContacts() async {
    setState(() => _isLoadingContacts = true);

    final status = await Permission.contacts.request();
    if (status.isGranted) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoadingContacts = false;
      });
    } else {
      setState(() => _isLoadingContacts = false);
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Contacts permission denied",
          backgroundColor: _red,
        );
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _allContacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _togglePersonSelection(Contact contact) {
    setState(() {
      final index =
          _selectedPeople.indexWhere((p) => p.contact.id == contact.id);
      if (index != -1) {
        _selectedPeople.removeAt(index);
        if (_tabController.index >= _selectedPeople.length &&
            _selectedPeople.isNotEmpty) {
          _tabController.index = _selectedPeople.length - 1;
        }
        _tabController = TabController(
          length: _selectedPeople.length,
          vsync: this,
          initialIndex: _selectedPeople.isEmpty ? 0 : _tabController.index,
        );
      } else {
        _selectedPeople.add(PersonExpense(contact: contact, expenses: []));
        _tabController = TabController(
          length: _selectedPeople.length,
          vsync: this,
          initialIndex: _selectedPeople.length - 1,
        );
      }
    });
  }

  void _addExpenseForPerson(int personIndex) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: _purpleSoft,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.receipt_long, color: _purple, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Expense',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _selectedPeople[personIndex].contact.displayName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner, Movie, Taxi',
                prefixIcon: Icon(Icons.description, color: _purple),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: _purple, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee, color: _purple),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: _purple, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final description = descController.text.trim();
              final amount = double.tryParse(amountController.text);

              if (description.isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please enter a description",
                  backgroundColor: _red,
                );
                return;
              }

              if (amount == null || amount <= 0) {
                Fluttertoast.showToast(
                  msg: "Please enter a valid amount",
                  backgroundColor: _red,
                );
                return;
              }

              setState(() {
                final updatedExpenses = List<ExpenseItem>.from(
                    _selectedPeople[personIndex].expenses)
                  ..add(ExpenseItem(description: description, amount: amount));
                _selectedPeople[personIndex] = _selectedPeople[personIndex]
                    .copyWith(expenses: updatedExpenses);
              });

              Navigator.pop(dialogContext);
              Fluttertoast.showToast(
                msg: "Expense added successfully",
                backgroundColor: _green,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeExpense(int personIndex, int expenseIndex) {
    setState(() {
      final updatedExpenses =
          List<ExpenseItem>.from(_selectedPeople[personIndex].expenses)
            ..removeAt(expenseIndex);
      _selectedPeople[personIndex] =
          _selectedPeople[personIndex].copyWith(expenses: updatedExpenses);
    });

    Fluttertoast.showToast(
      msg: "Expense removed",
      backgroundColor: _red,
    );
  }

  void _sendNotifications() {
    if (_selectedPeople.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select at least one person",
        backgroundColor: _red,
      );
      return;
    }

    bool hasExpenses =
        _selectedPeople.any((person) => person.expenses.isNotEmpty);
    if (!hasExpenses) {
      Fluttertoast.showToast(
        msg: "Please add at least one expense",
        backgroundColor: _red,
      );
      return;
    }

    // Show confirmation
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.send, color: _green, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              'Send Notifications?',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'This will notify ${_selectedPeople.length} ${_selectedPeople.length == 1 ? "person" : "people"} about their expenses.',
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              for (var person in _selectedPeople) {
                if (person.expenses.isNotEmpty) {
                  final total = person.totalAmount;
                  Fluttertoast.showToast(
                    msg:
                        "${person.contact.displayName} owes ₹${total.toStringAsFixed(2)}",
                    backgroundColor: _green,
                  );
                }
              }

              // Reset after sending
              Future.delayed(Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() {
                    _selectedPeople.clear();
                    _currentStep = 0;
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        title: Text(
          'Split Expense',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_selectedPeople.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _selectedPeople.clear();
                  _currentStep = 0;
                });
              },
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),

          // Content based on step
          Expanded(
            child: _currentStep == 0
                ? _buildSelectPeopleStep()
                : _buildAddExpensesStep(),
          ),

          // Bottom Summary Bar
          if (_selectedPeople.isNotEmpty) _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepItem(0, 'Select People', Icons.people),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 0 ? _purple : Colors.grey[300],
            ),
          ),
          _buildStepItem(1, 'Add Expenses', Icons.receipt_long),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? _purple : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? _purple : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectPeopleStep() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(20.w),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Lottie.asset("images/moneysplit.json",
                      height: 80.h, width: 80.w),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who are you splitting with?',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Select people to split expenses',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts',
                  prefixIcon: Icon(Icons.search, color: _purple),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: _purple, width: 2),
                  ),
                ),
                onChanged: _filterContacts,
              ),
            ],
          ),
        ),

        // Contacts List
        Expanded(
          child: _isLoadingContacts
              ? Center(
                  child: CircularProgressIndicator(color: _purple),
                )
              : _filteredContacts.isEmpty
                  ? _buildEmptyContactsState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        final isSelected = _selectedPeople
                            .any((p) => p.contact.id == contact.id);

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  isSelected ? _purple : _purpleSoft,
                              child: Text(
                                contact.displayName.isNotEmpty
                                    ? contact.displayName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: isSelected ? _purple : Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.check : Icons.add,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 20.sp,
                              ),
                            ),
                            onTap: () => _togglePersonSelection(contact),
                          ),
                        );
                      },
                    ),
        ),

        // Continue Button
        if (_selectedPeople.isNotEmpty)
          Container(
            padding: EdgeInsets.all(20.w),
            color: Colors.white,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _currentStep = 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Continue (${_selectedPeople.length} ${_selectedPeople.length == 1 ? "person" : "people"})',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddExpensesStep() {
    return Column(
      children: [
        // Tab Bar
        if (_selectedPeople.isNotEmpty)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: _purple,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: _purple,
              indicatorWeight: 3,
              tabs: _selectedPeople
                  .map((person) => Tab(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: _purpleSoft,
                              child: Text(
                                person.contact.displayName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: _purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(person.contact.displayName),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _selectedPeople.asMap().entries.map((entry) {
              final index = entry.key;
              final person = entry.value;
              return _buildPersonExpenseList(index, person);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonExpenseList(int personIndex, PersonExpense person) {
    return Column(
      children: [
        // Add Expense Button
        Container(
          padding: EdgeInsets.all(20.w),
          color: Colors.white,
          child: ElevatedButton.icon(
            onPressed: () => _addExpenseForPerson(personIndex),
            icon: Icon(Icons.add),
            label: Text('Add Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        // Expenses List
        Expanded(
          child: person.expenses.isEmpty
              ? _buildEmptyExpensesState()
              : ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: person.expenses.length,
                  itemBuilder: (context, expenseIndex) {
                    final expense = person.expenses[expenseIndex];
                    return _buildExpenseCard(
                        expense, personIndex, expenseIndex);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(
      ExpenseItem expense, int personIndex, int expenseIndex) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: _purpleSoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.receipt, color: _purple, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: _purple,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: _red),
            onPressed: () => _removeExpense(personIndex, expenseIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    final totalAmount = _selectedPeople.fold(
      0.0,
      (sum, person) => sum + person.totalAmount,
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _purple,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _purpleSoft,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_selectedPeople.length} ${_selectedPeople.length == 1 ? "person" : "people"}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _purple,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_currentStep == 1)
              ElevatedButton.icon(
                onPressed: _sendNotifications,
                icon: Icon(Icons.send),
                label: Text('Send Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContactsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No Contacts Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Make sure you have contacts saved',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpensesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: _purpleSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, size: 64.sp, color: _purple),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Expenses Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap "Add Expense" to get started',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
