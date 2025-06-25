import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AdvancedCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const AdvancedCalendar({super.key, required this.onDateSelected});

  @override
  AdvancedCalendarState createState() => AdvancedCalendarState();
}

class AdvancedCalendarState extends State<AdvancedCalendar> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _currentDate = ValueNotifier(DateTime.now());

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
      final days = _generateDaysInMonth(_currentDate.value);
      final indexOfToday =
          days.indexWhere((day) => day.day == _selectedDate.value.day);
      if (indexOfToday != -1) {
        _scrollController.animateTo(
          (indexOfToday * 95.0) - (MediaQuery.of(context).size.width / 2),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _currentDate.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _currentDate,
          builder: (context, currentDate, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => _currentDate.value = DateTime(
                    currentDate.year,
                    currentDate.month - 1,
                    currentDate.day,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Text(
                    DateFormat.yMMMM().format(currentDate),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _currentDate.value = DateTime(
                    currentDate.year,
                    currentDate.month + 1,
                    currentDate.day,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 16.h),
        ValueListenableBuilder<DateTime>(
          valueListenable: _currentDate,
          builder: (context, currentDate, _) {
            final days = _generateDaysInMonth(currentDate);
            return ValueListenableBuilder<DateTime>(
              valueListenable: _selectedDate,
              builder: (context, selectedDate, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children: [
                      for (var day in days)
                        GestureDetector(
                          onTap: () {
                            _selectedDate.value = day;
                            widget.onDateSelected(day);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            width: 70.r,
                            height: 70.r,
                            decoration: BoxDecoration(
                              gradient: selectedDate.day == day.day &&
                                      selectedDate.month == day.month &&
                                      selectedDate.year == day.year
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
                                  color: selectedDate.day == day.day &&
                                          selectedDate.month == day.month &&
                                          selectedDate.year == day.year
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
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate.value) {
      _selectedDate.value = picked;
      widget.onDateSelected(picked);
    }
  }
}
