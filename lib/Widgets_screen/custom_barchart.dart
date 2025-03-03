import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryBarChart extends StatelessWidget {
  final Map<String, double> categoryToAmount;

  const CategoryBarChart({super.key, required this.categoryToAmount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: BarChart(
        BarChartData(
          barGroups: categoryToAmount.entries.map((entry) {
            int index = categoryToAmount.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  width: 15.w,
                  gradient: LinearGradient(
                    colors: [
                      Colors.primaries[index % Colors.primaries.length]
                          .withOpacity(0.8),
                      Colors.primaries[index % Colors.primaries.length]
                          .withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: entry.value * 1.2,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '₹${value.toInt()}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      categoryToAmount.keys.toList()[value.toInt()],
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              fitInsideVertically: true,
              getTooltipColor: (group) =>
                  Colors.primaries[group.x % Colors.primaries.length],
              tooltipBorder: BorderSide.none,
              tooltipHorizontalAlignment: FLHorizontalAlignment.center,
              direction: TooltipDirection.auto,
              tooltipRoundedRadius: 15.r,
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${categoryToAmount.keys.toList()[group.x]}: ₹${rod.toY.toStringAsFixed(2)}\n',
                  TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
