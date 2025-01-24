import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:try1/Widgets_screen/adavance_calcander.dart';
import 'package:try1/screen/graph.dart';
import '../firebase_store/expense_store.dart';

class ExpenseSummaryPage extends StatefulWidget {
  const ExpenseSummaryPage({super.key});

  @override
  State<ExpenseSummaryPage> createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;
  DatePickerEntryMode? _currentDate;
  Color historyTabColor = Colors.deepOrangeAccent;
  Color graphTabColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
        title: const Text('Expense Summary'),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'Graph',
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
                    child: const Text(
                      'Total Balance is',
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
                                    'Income',
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
                                    'Expenses',
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
                    return const Center(child: Text('No expenses found.'));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                builder: (context) => DatePickerDialog(
                                    onDatePickerModeChange: (value) {
                                      setState(() {
                                        _currentDate = value;
                                        print('$_currentDate');
                                      });
                                    },
                                    initialCalendarMode: DatePickerMode.day,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime.now()),
                                context: context,
                                useSafeArea: true,
                                barrierDismissible: true,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Transactions",
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                const Spacer(),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Icon(
                                    Icons.date_range,
                                    size: 22.spMax,
                                  ),
                                ),
                                Text(
                                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: TextStyle(fontSize: 15.spMax),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: 15.h),
                      AdvancedCalendar(),
                      ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemCount: expenseStore.expenses.length,
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
                              child: Card(
                                color: Theme.of(context).cardColor,
                                elevation: 5,
                                child: ListTile(
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(expense.id);
                                    },
                                  ),
                                  leading: Column(
                                    children: [
                                      Text(expense.getFormattedDate()),
                                      Text(expense.getFormattedTime()),
                                    ],
                                  ),
                                  title: Text(
                                    expense.category,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  subtitle: Text(
                                      'Amount: ₹${expense.amount.toStringAsFixed(2)}'),
                                ),
                              ),
                            ),
                          );
                        },
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
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteExpense(id);
                showToast("Transaction Deleted!");
                Navigator.of(context).pop();
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
