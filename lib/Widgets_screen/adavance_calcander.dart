import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ─── Theme Constants ──────────────────────────────────────────────────────────
const _calPurple = Color(0xFF6A5AE0);
const _calPurpleLight = Color(0xFF8F7CFF);
const _calPurpleSoft = Color(0xFFF0EEFF);

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

  // Weekday abbreviations
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      last.difference(first).inDays + 1,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  void _scrollToToday() {
    final days = _generateDaysInMonth(_currentDate.value);
    final index = days.indexWhere((d) => d.day == _selectedDate.value.day);
    if (index != -1) {
      _scrollController.animateTo(
        (index * 68.0) - (MediaQuery.of(context).size.width / 2) + 34,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
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
        // ── Month navigator ──────────────────────────────────────────────────
        ValueListenableBuilder<DateTime>(
          valueListenable: _currentDate,
          builder: (_, currentDate, __) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _currentDate.value = DateTime(
                  currentDate.year,
                  currentDate.month - 1,
                  1,
                ),
              ),

              // Month + year label — tap to pick via system picker
              GestureDetector(
                onTap: () => _selectMonthYear(context, currentDate),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _calPurpleSoft,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat.yMMMM().format(currentDate),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _calPurple,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: _calPurple, size: 18),
                    ],
                  ),
                ),
              ),

              _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _currentDate.value = DateTime(
                  currentDate.year,
                  currentDate.month + 1,
                  1,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // ── Day scroll strip ─────────────────────────────────────────────────
        ValueListenableBuilder<DateTime>(
          valueListenable: _currentDate,
          builder: (_, currentDate, __) {
            final days = _generateDaysInMonth(currentDate);
            return ValueListenableBuilder<DateTime>(
              valueListenable: _selectedDate,
              builder: (_, selectedDate, __) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: days.map((day) {
                    final isSelected = day.day == selectedDate.day &&
                        day.month == selectedDate.month &&
                        day.year == selectedDate.year;
                    final isToday = day.day == DateTime.now().day &&
                        day.month == DateTime.now().month &&
                        day.year == DateTime.now().year;
                    final weekdayIndex = (day.weekday - 1) % 7;

                    return GestureDetector(
                      onTap: () {
                        _selectedDate.value = day;
                        widget.onDateSelected(day);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: 52.r,
                        height: 68.r,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [_calPurple, _calPurpleLight],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : null,
                          color: isSelected
                              ? null
                              : isToday
                                  ? _calPurpleSoft
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: _calPurple.withOpacity(0.4),
                                  width: 1.5)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _calPurple.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Weekday letter
                            Text(
                              _weekdays[weekdayIndex],
                              style: TextStyle(
                                fontSize: 10.spMin,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey.shade400,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            // Day number
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 17.spMin,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? _calPurple
                                        : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectMonthYear(BuildContext context, DateTime current) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _calPurple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _calPurple),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _currentDate.value = DateTime(picked.year, picked.month, 1);
      _selectedDate.value = picked;
      widget.onDateSelected(picked);
    }
  }
}

// ─── Nav Button ───────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: _calPurple, size: 20),
      ),
    );
  }
}
