import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:try1/screen/graph.dart';
import '../firebase_store/expense_store.dart';

class ExpenseSummaryPage extends StatefulWidget {
  const ExpenseSummaryPage({super.key});

  @override
  State<ExpenseSummaryPage> createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Observer(
                    builder: (_) {
                      if (expenseStore.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (expenseStore.expenses.isEmpty) {
                        return const Center(child: Text('No expenses found.'));
                      }
                      return ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemCount: expenseStore.expenses.length,
                        itemBuilder: (BuildContext context, int index) {
                          final expense = expenseStore.expenses[index];

                          return Card(
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
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                  'Amount: ₹${expense.amount.toStringAsFixed(2)}'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildSummaryDetails(expenseStore),
              ],
            ),
          ),
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

  Widget _buildSummaryDetails(ExpenseStore expenseStore) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                'Total Amount: ₹${expenseStore.totalExpenses.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Current Income: ₹${expenseStore.totalIncome.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Balance Left: ₹${expenseStore.leftBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
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
