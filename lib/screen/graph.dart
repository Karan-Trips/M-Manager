import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:try1/utils/model.dart';

import '../firebase_store/expense_store.dart';

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  bool isDarkMode = false;
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    expenseStore.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode =
        ThemeProvider.themeOf(context).data.brightness == Brightness.dark;

    return Scaffold(
      body: Observer(
        builder: (context) {
          if (expenseStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Expense> documents = expenseStore.expenses;
          if (documents.isEmpty) {
            return const Center(child: Text("No expenses found."));
          }

          Map<String, int> categoryToCount = {};
          Map<String, double> categoryToAmount = {};

          for (var doc in documents) {
            dynamic category = doc.category;
            dynamic amount = doc.amount;

            if (category != null && amount != null) {
              String categoryString = category.toString();
              double amountDouble = (amount is num) ? amount.toDouble() : 0.0;

              categoryToAmount[categoryString] =
                  (categoryToAmount[categoryString] ?? 0.0) + amountDouble;
              categoryToCount[categoryString] =
                  (categoryToCount[categoryString] ?? 0) + 1;
            }
          }

          List<PieChartSectionData> pieChartSections = [];
          List<String> legendTitles = [];
          int index = 0;

          categoryToAmount.forEach((category, amount) {
            int count = categoryToCount[category] ?? 0;

            if (count > 0) {
              final isTouched = index == touchedIndex;
              final double radius = isTouched ? 130.0 : 100.0;

              pieChartSections.add(
                PieChartSectionData(
                  title: category,
                  value: amount,
                  color: Colors.primaries[index % Colors.primaries.length],
                  radius: radius,
                  titleStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );

              legendTitles.add(
                '$category: ₹${amount.toStringAsFixed(2)} ($count entries)',
              );
              index++;
            }
          });

          return Column(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    borderData: FlBorderData(show: false),
                    centerSpaceRadius: 40,
                    sectionsSpace: 0,
                    pieTouchData: PieTouchData(
                      touchCallback:
                          (FlTouchEvent event, PieTouchResponse? response) {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          setState(() {
                            touchedIndex = -1;
                          });
                          return;
                        }
                        setState(() {
                          touchedIndex =
                              response!.touchedSection!.touchedSectionIndex;
                          final touchedCategory =
                              categoryToAmount.keys.toList()[touchedIndex!];
                          final touchedAmount =
                              categoryToAmount[touchedCategory] ?? 0;
                          final touchedCount =
                              categoryToCount[touchedCategory] ?? 0;

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(touchedCategory),
                                content: Text(
                                  'Total Amount: ₹${touchedAmount.toStringAsFixed(2)}\n'
                                  'Entries: $touchedCount',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        });
                      },
                      enabled: true,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendTitles
                      .map(
                        (title) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
