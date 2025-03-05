import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:try1/utils/model.dart';
import 'package:try1/widgets_screen/custom_barchart.dart';

import '../../firebase_store/expense_store.dart';
import '../../generated/l10n.dart';

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  bool isDarkMode = false;
  bool isBarchart = false;
  int? touchedIndex;
  double? totalAmount;
  double? perAmount;
  List<String> image = [];

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
            return Center(child: Lottie.asset('images/loading.json'));
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
            perAmount = amount;

            if (count > 0) {
              final isTouched = index == touchedIndex;
              final double radius = isTouched ? 90.0 : 80.0;

              pieChartSections.add(
                PieChartSectionData(
                  title: '${calculatePercentage(amount)}%',
                  value: amount,
                  color: Colors.primaries[index % Colors.primaries.length],
                  radius: radius,
                  titleStyle: TextStyle(
                    color: isDarkMode ? Colors.black : Colors.white,
                    fontSize: 13.spMax,
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
              image.add(category);
              legendTitles.add(
                '$category: ₹${amount.toStringAsFixed(2)} ($count entries)',
              );
              index++;
            }
          });

          return Column(
            children: [
              30.verticalSpace,
              Expanded(
                child: isBarchart
                    ? Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sections: pieChartSections,
                              titleSunbeamLayout: true,
                              borderData: FlBorderData(
                                show: false,
                              ),
                              centerSpaceRadius: 90,
                              sectionsSpace: 0,
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event,
                                    PieTouchResponse? response) {
                                  if (!event.isInterestedForInteractions ||
                                      response?.touchedSection == null) {
                                    setState(() {
                                      touchedIndex = -1;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    touchedIndex = response!
                                        .touchedSection!.touchedSectionIndex;
                                    final touchedCategory = categoryToAmount
                                        .keys
                                        .toList()[touchedIndex ?? 0];
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
                                              child: Text(S.of(context).close),
                                              onPressed: () {
                                                Get.back();
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
                          Center(
                            child: Text(
                              '${calculatePercenategeTotal()}% of Income',
                              style: TextStyle(
                                fontSize: 16.spMax,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                          right: 12.w,
                          left: 12.w,
                        ),
                        child: CategoryBarChart(
                          categoryToAmount: categoryToAmount,
                        )),
              ),
              Padding(
                padding: EdgeInsets.only(top: 25.h),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isBarchart = !isBarchart;
                    });
                  },
                  child: Text(S.of(context).barchart),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SvgPicture.asset(
                          height: 40.h,
                          imageSelect(image[index]),
                        ),
                        Text(
                          legendTitles[index],
                          style: TextStyle(
                            fontSize: 14.spMax,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: pieChartSections[index].color,
                          radius: 10,
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: legendTitles.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String imageSelect(String type) {
    switch (type) {
      case 'Fast-Food':
        return 'images/svgs/fastfood.svg';
      case 'Groceries':
        return 'images/svgs/grocory.svg';
      case 'Medicine':
        return 'images/svgs/medical.svg';
      case 'Office':
        return 'images/svgs/office.svg';
      case 'Ghumne':
        return 'images/svgs/travel.svg';
      case 'Other':
        return 'images/svgs/emi.svg';
      case 'Food':
        return 'images/svgs/fastfood.svg';
      default:
        return 'images/svgs/emi.svg';
    }
  }

  String calculatePercentage(double amount) {
    final totalAmount = expenseStore.totalExpenses;
    final percentage = (amount / totalAmount) * 100;
    return percentage.toStringAsFixed(1);
  }

  int calculatePercenategeTotal() {
    final totalAmount = expenseStore.totalExpenses;
    final totalIncome = expenseStore.totalIncome;
    final percentage = (totalAmount / totalIncome) * 100;
    if (percentage > 0) {
      return percentage.toInt();
    }
    return percentage.toInt();
  }
}
