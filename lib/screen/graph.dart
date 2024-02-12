import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:theme_provider/theme_provider.dart';

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    isDarkMode =
        ThemeProvider.themeOf(context).data.brightness == Brightness.dark;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('expenses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            Map<String, int> categoryToCount = {};
            Map<String, double> categoryToAmount = {};

            for (var doc in documents) {
              dynamic category = doc['category'];

              dynamic amount = doc['amount'];

              if (category != null && amount != null) {
                String categoryString = category.toString();

                double amountDouble = (amount is num) ? amount.toDouble() : 0.0;

                if (categoryToAmount.containsKey(categoryString)) {
                  categoryToAmount[categoryString] =
                      (categoryToAmount[categoryString] ?? 0.0) + amountDouble;
                } else {
                  categoryToAmount[categoryString] = amountDouble;
                }

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
                pieChartSections.add(PieChartSectionData(
                  title: category,
                  value: amount,
                  color: Colors.primaries[index % Colors.primaries.length],
                  radius: 100,
                  titleStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16),
                ));

                legendTitles.add(
                  '$category: $amount ($count entries)',
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
                          // TODO  touch response add karna hai
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
                    color: Colors.grey[200],
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
                                color: isDarkMode ? Colors.black : Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
