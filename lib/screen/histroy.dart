// ignore_for_file: avoid_print, invalid_return_type_for_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:try1/screen/graph.dart';

class ExpenseSummaryPage extends StatefulWidget {
  const ExpenseSummaryPage({super.key});

  @override
  State<ExpenseSummaryPage> createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _expenseData;
  double currentIncome = 0.0;
  bool showDetails = false;
  bool iconChange = false;
  late TabController _tabController;
  int selectedIndex = 0;

  // Define colors for tabs
  Color historyTabColor = Colors.deepOrangeAccent;
  Color graphTabColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _expenseData = fetchExpenseData();
    fetchCurrentIncome();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCurrentIncome() async {
    try {
      CollectionReference incomes =
          FirebaseFirestore.instance.collection('incomes');

      DocumentReference incomeDocument = incomes.doc('income_document');

      DocumentSnapshot documentSnapshot = await incomeDocument.get();

      if (documentSnapshot.exists) {
        setState(() {
          currentIncome =
              (documentSnapshot.data() as Map<String, dynamic>)['income'] ??
                  0.0;
        });
      }
    } catch (error) {
      print("Failed to fetch current income: $error");
    }
  }

  Future<List<Map<String, dynamic>>> fetchExpenseData(
      {bool sortByDate = false}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .orderBy('date', descending: sortByDate)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  double calculateTotal(List<Map<String, dynamic>> expenses) {
    return expenses.fold(
        0.0, (total, expense) => total + (expense['amount'] ?? 0.0));
  }

  double calculateLeftBalance(
      double currentIncome, List<Map<String, dynamic>> expenses) {
    double totalAmount = calculateTotal(expenses);
    return currentIncome - totalAmount;
  }

  void deleteExpense(String documentId) {
    FirebaseFirestore.instance
        .collection('expenses')
        .doc(documentId)
        .delete()
        .then((value) {
      print('Expense deleted');

      setState(() {
        _expenseData = fetchExpenseData();
      });
    }).catchError((error) => print('Failed to delete expense: $error'));

    // Change colors when deleting an expense
    setState(() {
      historyTabColor = Colors.blue; // Change color for "History" tab
      graphTabColor = Colors.green; // Change color for "Graph" tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _expenseData = fetchExpenseData(sortByDate: true);

              print("sort");
            },
            icon: const Icon(Icons.sort_sharp),
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _expenseData,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No expenses found.'));
                    }
                    return Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Theme.of(context).cardColor,
                            elevation: 5,
                            child: ListTile(
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                            'Are you sure you want to delete this?'),
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
                                              setState(() {
                                                deleteExpense(snapshot
                                                    .data![index]['id']);
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              leading: Column(
                                children: [
                                  Text('${snapshot.data![index]['date']}'),
                                  Text('${snapshot.data![index]['time']}'),
                                ],
                              ),
                              title: Text(
                                '${snapshot.data![index]['category']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Column(
                                children: [
                                  Text(
                                      'Amount: ${snapshot.data![index]['amount']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _expenseData,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    } else {
                      double totalAmount = calculateTotal(snapshot.data!);
                      double leftBalance =
                          calculateLeftBalance(currentIncome, snapshot.data!);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            showDetails = !showDetails;
                            iconChange;
                          });
                        },
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      'Total Amount: $totalAmount',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(iconChange
                                            ? Icons.arrow_drop_up_sharp
                                            : Icons.arrow_drop_down_rounded)),
                                  ],
                                ),
                                if (showDetails) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Current Income: $currentIncome',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Balance Left: $leftBalance',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const ExpenseGraphPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: selectedIndex == 0 ? historyTabColor : graphTabColor,
        selectedIconTheme: IconThemeData(
          color: selectedIndex == 0 ? historyTabColor : graphTabColor,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.deepOrangeAccent,
        ),
        unselectedItemColor: Colors.deepOrangeAccent,
        items: const <BottomNavigationBarItem>[
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
}
