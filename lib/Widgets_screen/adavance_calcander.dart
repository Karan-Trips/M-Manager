// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AdvancedCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const AdvancedCalendar({super.key, required this.onDateSelected});

  @override
  _AdvancedCalendarState createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final indexOfCurrentDate = _generateDaysInMonth(_currentDate)
          .indexWhere((day) => day.day == _currentDate.day);
      if (indexOfCurrentDate != -1) {
        _scrollController.animateTo(
          (indexOfCurrentDate * 95.0) - (MediaQuery.of(context).size.width / 2),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
              onTap: () async {
                _selectDate(context);
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
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: [
              for (var day in _generateDaysInMonth(_currentDate))
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                    widget.onDateSelected(_selectedDate);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    width: 70.r,
                    height: 70.r,
                    decoration: BoxDecoration(
                      gradient: _selectedDate.day == day.day
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color.fromARGB(255, 243, 183, 93),
                                Color.fromARGB(255, 245, 130, 29),
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
                          fontSize: 18.spMin,
                          fontWeight: FontWeight.w500,
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
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateSelected(_selectedDate);
      });
    }
  }
}
