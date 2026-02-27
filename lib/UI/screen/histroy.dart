import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:m_manager/widgets_screen/adavance_calcander.dart';
import 'package:m_manager/firebase_store/expense_store.dart';
import 'package:m_manager/ui/screen/graph.dart';

import '../../generated/l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────────────────────

const _purple = Color(0xFF6A5AE0);
const _purpleDark = Color(0xFF4527A0);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseSummaryPage extends StatefulWidget {
  const ExpenseSummaryPage({super.key});

  @override
  State<ExpenseSummaryPage> createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // Calendar visibility — drives animated show/hide
  bool _calendarVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      expenseStore.fetchExpenses();
      expenseStore.fetchIncome();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Called by AdvancedCalendar when user taps a day
  void _onDateSelected(DateTime date) {
    // 🔥 Fetch from Firebase filtered by this date
    expenseStore.fetchExpensesByDate(date);
  }

  // Called by Clear chip / refresh button
  void _clearFilter() {
    expenseStore.clearDateFilter();
    setState(() => _calendarVisible = false);
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _purple,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await expenseStore.deleteExpense(id);
      _showToast("Expense deleted successfully");
    } catch (e) {
      debugPrint("Delete error: $e");
      _showToast("Error deleting expense");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHistoryTab(),
          const ExpenseGraphPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _bg,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: _purple),
      centerTitle: true,
      title: Text(
        S.of(context).expenseSummary,
        style: TextStyle(
          color: _purple,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _purple, size: 20),
            onPressed: () {
              _clearFilter();
              expenseStore.fetchExpenses();
              expenseStore.fetchIncome();
            },
          ),
        ),
      ],
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: _purple.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.history_rounded,
                  label: S.of(context).history,
                  isSelected: _selectedTab == 0,
                  activeColor: _purple,
                  onTap: () {
                    _tabController.animateTo(0);
                    setState(() => _selectedTab = 0);
                  },
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: S.of(context).graph,
                  isSelected: _selectedTab == 1,
                  activeColor: _green,
                  onTap: () {
                    _tabController.animateTo(1);
                    setState(() => _selectedTab = 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── History Tab ──────────────────────────────────────────────────────────
  Widget _buildHistoryTab() {
    return Observer(builder: (_) {
      // MobX observables — UI rebuilds automatically when these change
      final income = expenseStore.totalIncome;
      final totalExp = expenseStore.totalExpenses;
      final balance = expenseStore.leftBalance;
      final isFiltered = expenseStore.activeFilterDate != null;
      final activeDate = expenseStore.activeFilterDate;
      final isLoading = expenseStore.isLoading || expenseStore.isFilterLoading;

      // ✅ Key: switch between filtered list and full list
      final displayList =
          isFiltered ? expenseStore.filteredExpenses : expenseStore.expenses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Card ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
            child: _SummaryCard(
              balance: balance,
              income: income,
              expenses: totalExp,
            ),
          ),

          SizedBox(height: 20.h),

          // ── Header Row ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // Purple accent bar
                Container(
                  width: 4,
                  height: 18.h,
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Title changes based on filter state
                Text(
                  isFiltered ? _formatDate(activeDate!) : "All Transactions",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),

                // Clear filter chip — only visible when filter is active
                if (isFiltered)
                  GestureDetector(
                    onTap: _clearFilter,
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.close_rounded, size: 13, color: _red),
                          SizedBox(width: 4.w),
                          Text("Clear",
                              style: TextStyle(
                                  color: _red,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                // Calendar toggle button
                GestureDetector(
                  onTap: () =>
                      setState(() => _calendarVisible = !_calendarVisible),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _calendarVisible ? _purple : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Icon(
                      _calendarVisible
                          ? Icons.calendar_today_rounded
                          : Icons.filter_list_rounded,
                      size: 18,
                      color: _calendarVisible ? Colors.white : _purple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // ── Calendar Panel (animated) ────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: _calendarVisible
                ? Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                            color: _purple.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: AdvancedCalendar(
                      // ✅ Wired: date tap → fetchExpensesByDate → list rebuilds
                      onDateSelected: _onDateSelected,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: 4.h),

          // ── Filtered summary pill ────────────────────────────────────────
          if (isFiltered && displayList.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 14, color: _red),
                    SizedBox(width: 6.w),
                    Text(
                      "${displayList.length} "
                      "transaction${displayList.length == 1 ? '' : 's'}"
                      "  •  - ₹${expenseStore.filteredTotal.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Transaction List ─────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? Center(
                    child: Lottie.asset('images/loading.json', height: 120.h),
                  )
                : displayList.isEmpty
                    ? _EmptyTransactions(
                        isFiltered: isFiltered,
                        date: activeDate,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final expense = displayList[index];
                          return Dismissible(
                            key: Key(expense.id),
                            direction: DismissDirection.endToStart,
                            background: const _DeleteBackground(),
                            onDismissed: (_) => _deleteExpense(expense.id),
                            child: _TransactionCard(expense: expense),
                          );
                        },
                      ),
          ),
        ],
      );
    });
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${d.day} ${months[d.month]} ${d.year}";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? activeColor : Colors.black38, size: 20),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Text(label,
                  style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double balance, income, expenses;
  const _SummaryCard({
    required this.balance,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4DD9), Color(0xFF8B6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: _purple.withOpacity(0.4),
              blurRadius: 28,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Column(
              children: [
                const Text("Total Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 6.h),
                Text(
                  "₹ $balance",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _CardStat(
                    label: "Income",
                    value: "₹$income",
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF4ADE80),
                  ),
                ),
                VerticalDivider(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                    thickness: 1,
                    indent: 12,
                    endIndent: 12),
                Expanded(
                  child: _CardStat(
                    label: "Expenses",
                    value: "₹$expenses",
                    icon: Icons.trending_down_rounded,
                    color: const Color(0xFFFCA5A5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _CardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 14),
              ),
              SizedBox(width: 6.w),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          SizedBox(height: 5.h),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSACTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final dynamic expense;
  const _TransactionCard({required this.expense});

  IconData _icon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('food') || c.contains('eat') || c.contains('restaurant')) {
      return Icons.restaurant_rounded;
    }
    if (c.contains('emi') || c.contains('loan')) {
      return Icons.account_balance_rounded;
    }
    if (c.contains('travel') || c.contains('transport') || c.contains('fuel')) {
      return Icons.directions_car_rounded;
    }
    if (c.contains('shopping') || c.contains('shop')) {
      return Icons.shopping_bag_rounded;
    }
    if (c.contains('health') || c.contains('medical')) {
      return Icons.medical_services_rounded;
    }
    if (c.contains('entertain') || c.contains('movie')) {
      return Icons.movie_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  Color _color(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('food') || c.contains('eat')) return const Color(0xFFF59E0B);
    if (c.contains('emi') || c.contains('loan')) return const Color(0xFF6A5AE0);
    if (c.contains('travel') || c.contains('transport')) {
      return const Color(0xFF0EA5E9);
    }
    if (c.contains('shopping')) return const Color(0xFFEC4899);
    if (c.contains('health')) return const Color(0xFF22C55E);
    return const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(expense.category);
    final amount = expense.amount.toStringAsFixed(0);

    return Bounceable(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              height: 48.r,
              width: 48.r,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(_icon(expense.category), color: color, size: 22.r),
            ),

            SizedBox(width: 14.w),

            // Name + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: _purpleDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 11, color: Colors.grey.shade400),
                      SizedBox(width: 4.w),
                      Text(
                        expense.getFormattedDate(),
                        style: TextStyle(
                            fontSize: 11.spMin, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "- ₹$amount",
                style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: _red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEF4444)]),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 24),
          SizedBox(height: 4.h),
          const Text("Delete",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyTransactions extends StatelessWidget {
  final bool isFiltered;
  final DateTime? date;

  const _EmptyTransactions({
    required this.isFiltered,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Lottie.asset(
          'images/empty.json',
          height: 100.h,
          width: 1.sw,
          repeat: true,
        ),
      ),
    );
  }
}
