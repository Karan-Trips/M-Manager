// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AdvancedCalendar extends StatefulWidget {
  const AdvancedCalendar({super.key});

  @override
  _AdvancedCalendarState createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;

    return List.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                setState(() {
                  _currentDate = DateTime(
                    _currentDate.year,
                    _currentDate.month - 1,
                    _currentDate.day,
                  );
                });
              },
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  builder: (context) => DatePickerDialog(
                      initialCalendarMode: DatePickerMode.day,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2025),
                      lastDate: DateTime.now()),
                  context: context,
                  useSafeArea: true,
                  barrierDismissible: true,
                );
              },
              child: Text(
                DateFormat.yMMMM().format(_currentDate),
                style: TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                setState(() {
                  _currentDate = DateTime(
                    _currentDate.year,
                    _currentDate.month + 1,
                    _currentDate.day,
                  );
                });
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        Observer(builder: (_) {
          final brightness = MediaQuery.of(context).platformBrightness;
          final isDarkMode = brightness == Brightness.dark;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var day in _generateDaysInMonth(_currentDate))
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      width: 70.r,
                      height: 70.r,
                      decoration: BoxDecoration(
                        gradient: _selectedDate.day == day.day
                            ? isDarkMode
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
                                  )
                            : null,
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: _selectedDate.day == day.day
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
