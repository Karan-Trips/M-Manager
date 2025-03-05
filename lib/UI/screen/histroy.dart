import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:try1/widgets_screen/adavance_calcander.dart';
import 'package:try1/firebase_store/expense_store.dart';
import 'package:try1/UI/screen/graph.dart';
import 'package:try1/utils/model.dart';

import '../../generated/l10n.dart';

class ExpenseSummaryPage extends StatefulWidget {
  const ExpenseSummaryPage({super.key});

  @override
  State<ExpenseSummaryPage> createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  DateTime _selectedDate = DateTime.now();
  ValueNotifier<bool> isShowingDatePicker = ValueNotifier(false);
  Color historyTabColor = Colors.deepOrangeAccent;
  Color graphTabColor = Colors.green;
  List<Expense> _filteredExpenses = [];

  void _filterExpenses() {
    _filteredExpenses = expenseStore.expenses.where((expense) {
      final expenseDate = expense.date;
      return expenseDate.year == _selectedDate.year &&
          expenseDate.month == _selectedDate.month &&
          expenseDate.day == _selectedDate.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filterExpenses();
    _tabController.addListener(() {
      setState(() {
        selectedIndex = _tabController.index;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      expenseStore.fetchExpenses();
      expenseStore.fetchIncome();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              expenseStore.fetchExpenses();
              expenseStore.fetchIncome();
            },
            icon: const Icon(Icons.replay_outlined),
          ),
        ],
        backgroundColor:
            ThemeProvider.themeOf(context).data.appBarTheme.backgroundColor,
        title: Text(S.of(context).expenseSummary),
        centerTitle: true,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          histroy(),
          const ExpenseGraphPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: selectedIndex == 0 ? historyTabColor : graphTabColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: S.of(context).history,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: S.of(context).graph,
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          _tabController.animateTo(index);
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  Padding histroy() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Observer(builder: (_) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff3a3a3a),
                          Color(0xff555555),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromARGB(255, 243, 183, 93),
                          Color.fromARGB(255, 245, 130, 29),
                          Color.fromARGB(255, 243, 183, 93),
                        ],
                      ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(47, 125, 121, 0.3),
                    offset: Offset(1, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      S.of(context).totalBalanceIs,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      '₹ ${expenseStore.totalExpenses}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Divider(
                    height: 1.h,
                    color: Colors.amber,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 25.w),
                                  Image.asset(
                                    'images/pngs/up.png',
                                    scale: 15.w,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    S.of(context).income,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 216, 216, 216),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${expenseStore.totalIncome}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.green[400]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 65.h,
                          width: 1.w,
                          color: Colors.amber,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 25.w),
                                  Image.asset(
                                    'images/pngs/down.png',
                                    scale: 15.w,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    S.of(context).expenses,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 216, 216, 216),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${expenseStore.totalExpenses}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.green[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (expenseStore.isLoading) {
                    return Center(child: Lottie.asset('images/loading.json'));
                  }
                  if (expenseStore.expenses.isEmpty) {
                    return Center(child: Text(S.of(context).noExpensesFound));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                "Transactions",
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  isShowingDatePicker.value =
                                      !isShowingDatePicker.value;
                                },
                                child: ValueListenableBuilder(
                                  valueListenable: isShowingDatePicker,
                                  builder: (context, value, child) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Icon(
                                      isShowingDatePicker.value
                                          ? Icons.view_comfy_alt_outlined
                                          : Icons.view_compact_alt_outlined,
                                      size: 22.spMax,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 10.h),
                      ValueListenableBuilder(
                        valueListenable: isShowingDatePicker,
                        builder: (context, value, child) => Visibility(
                          visible: value,
                          child: AdvancedCalendar(
                            onDateSelected: (selectedDate) {
                              setState(() {
                                _selectedDate = selectedDate;
                                _filterExpenses();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // isShowingDatePicker.value?
                      // _filteredExpenses.isEmpty
                      //     ? Center(
                      //         child: Text(
                      //           'No expenses available for the selected date',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //       )
                      //     :
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount:
                              // isShowingDatePicker.value
                              //     ? _filteredExpenses.length
                              // :
                              expenseStore.expenses.length,
                          itemBuilder: (BuildContext context, int index) {
                            final expense = expenseStore.expenses[index];

                            return Dismissible(
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) =>
                                  deleteExpense(expense.id),
                              background: slideLeftBackground(),
                              key: Key(expense.id),
                              child: Bounceable(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.green[400]!,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Text(
                                        "₹ ${expense.amount.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontSize: 18.spMin,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense.category,
                                            style: TextStyle(
                                              fontSize: 16.spMin,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 2,
                                          ),
                                          Text(
                                            expense.getFormattedDate(),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.h),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmationDialog(
                                              expense.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).confirmDeletion),
          content: const Text('Are you sure you want to delete this?'),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () {
                // Navigator.of(context).pop();
                Get.back();
              },
            ),
            TextButton(
              child: Text(S.of(context).delete),
              onPressed: () {
                deleteExpense(id);
                showToast(S.of(context).transactionDeleted);
                // Navigator.of(context).pop();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  Widget slideLeftBackground() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: Colors.red,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void deleteExpense(String id) async {
    try {
      await expenseStore.deleteExpense(id);
      await expenseStore.fetchExpenses();
      showToast("Expense Deleted!");
    } catch (error) {
      print("Error deleting expense: $error");
      showToast("Error deleting expense");
    }
  }
}
