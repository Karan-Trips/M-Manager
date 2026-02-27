import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/model.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../firebase_store/expense_store.dart';
import '../../widgets_screen/custom_barchart.dart';

class ExpenseGraphPage extends StatefulWidget {
  const ExpenseGraphPage({super.key});

  @override
  State<ExpenseGraphPage> createState() => _ExpenseGraphPageState();
}

class _ExpenseGraphPageState extends State<ExpenseGraphPage> {
  bool isBarchart = false;
  int? touchedIndex;

  /// Lavender Theme Colors
  final Color lavenderPrimary = const Color(0xFF7E57C2);
  final Color lavenderLight = const Color(0xFFEDE7F6);
  final Color lavenderDark = const Color(0xFF5E35B1);
  final Color lavenderBg = const Color(0xFFF3EFFF);

  final List<Color> lavenderPalette = const [
    Color(0xFFB39DDB),
    Color(0xFF9575CD),
    Color(0xFF7E57C2),
    Color(0xFF673AB7),
    Color(0xFFD1C4E9),
  ];

  @override
  void initState() {
    super.initState();
    expenseStore.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavenderBg,
      body: Observer(
        builder: (_) {
          if (expenseStore.isLoading) {
            return Center(
              child: Lottie.asset('images/loading.json', height: 150.h),
            );
          }

          List<Expense> documents = expenseStore.expenses;
          if (documents.isEmpty) {
            return Center(
              child: Text(
                "No expenses found",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: lavenderDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          Map<String, double> categoryToAmount = {};
          Map<String, int> categoryToCount = {};

          for (var doc in documents) {
            final category = doc.category.toString();
            final amount = doc.amount.toDouble();

            categoryToAmount[category] =
                (categoryToAmount[category] ?? 0.0) + amount;
            categoryToCount[category] = (categoryToCount[category] ?? 0) + 1;
          }

          List<PieChartSectionData> sections = [];
          List<String> legends = [];
          List<String> categories = [];

          int index = 0;
          categoryToAmount.forEach((category, amount) {
            final count = categoryToCount[category] ?? 0;
            final isTouched = index == touchedIndex;

            sections.add(
              PieChartSectionData(
                value: amount,
                title: '${_calculatePercentage(amount)}%',
                radius: isTouched ? 90 : 80,
                color: lavenderPalette[index % lavenderPalette.length],
                titleStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            );

            legends.add("$category : ₹${amount.toStringAsFixed(2)} ($count)");
            categories.add(category);
            index++;
          });

          return Column(
            children: [
              40.verticalSpace,

              /// Chart Section
              Expanded(
                child: isBarchart
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: CategoryBarChart(
                          categoryToAmount: categoryToAmount,
                        ),
                      )
                    : Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sections: sections,
                              borderData: FlBorderData(show: false),
                              centerSpaceRadius: 85,
                              sectionsSpace: 3,
                              pieTouchData: PieTouchData(
                                enabled: true,
                                touchCallback: (event, response) {
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
                                  });
                                },
                              ),
                            ),
                          ),

                          /// Center Info
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${_calculateTotalPercent()}%",
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: lavenderDark,
                                  ),
                                ),
                                Text(
                                  "of Income Used",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              /// Toggle Button
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lavenderPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                  ),
                  onPressed: () {
                    setState(() {
                      isBarchart = !isBarchart;
                    });
                  },
                  child: Text(
                    isBarchart ? "Show Pie Chart" : "Show Bar Chart",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              /// Legend Section
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: legends.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: lavenderPrimary.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: sections[index].color,
                            radius: 12,
                          ),
                          12.horizontalSpace,
                          Expanded(
                            child: Text(
                              legends[index],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: lavenderDark,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            imageSelect(categories[index]),
                            height: 30.h,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Helper Methods

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

  String _calculatePercentage(double amount) {
    final total = expenseStore.totalExpenses;
    return ((amount / total) * 100).toStringAsFixed(1);
  }

  int _calculateTotalPercent() {
    final totalExpense = expenseStore.totalExpenses;
    final totalIncome = expenseStore.totalIncome;
    return ((totalExpense / totalIncome) * 100).toInt();
  }
}
