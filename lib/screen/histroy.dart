// ignore_for_file: avoid_print, invalid_return_type_for_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class ExpenseSummaryPage extends StatefulWidget {
  const ExpenseSummaryPage({super.key});

  @override
  State<ExpenseSummaryPage> createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage> {
  late Future<List<Map<String, dynamic>>> _expenseData;

  @override
  void initState() {
    super.initState();
    _expenseData = fetchExpenseData();
  }

  Future<List<Map<String, dynamic>>> fetchExpenseData() async {
    List<Map<String, dynamic>> expenseList = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('expenses').get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      expenseList.add(data);
    }

    return expenseList;
  }

  double calculateTotal(List<Map<String, dynamic>> expenses) {
    double totalAmount = 0.0;
    for (var expense in expenses) {
      totalAmount += expense['amount'];
    }
    return totalAmount;
  }

  void deleteExpense(String documentId) {
    FirebaseFirestore.instance
        .collection('expenses')
        .doc(documentId)
        .delete()
        .then((value) {
      print('Expense deleted');
      // Fetch updated data after deleting an item
      setState(() {
        _expenseData = fetchExpenseData();
      });
    }).catchError((error) => print('Failed to delete expense: $error'));
  }

  List<Map<String, dynamic>> expenseList = [];
  void sortExpensesByDate() {
    setState(() {
      expenseList.sort((a, b) {
        DateTime dateTimeA = DateTime.parse(a['date']['time']);
        DateTime dateTimeB = DateTime.parse(b['date']['time']);
        return dateTimeA.compareTo(dateTimeB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: sortExpensesByDate, icon: const Icon(Icons.sort_sharp))
        ],
        backgroundColor:
            ThemeProvider.themeOf(context).data.appBarTheme.backgroundColor,
        title: const Text('Expense Summary'),
        centerTitle: true,
      ),
      body: Padding(
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
                  // Handle the error here
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
                        // color: Colors.amberAccent,
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
                                              deleteExpense(
                                                  snapshot.data![index]['id']);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: Text(
                        'Total Amount: $totalAmount',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
