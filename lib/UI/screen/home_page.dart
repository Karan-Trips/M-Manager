// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m_manager/ui/cubits_app/cubits_app.dart';
import 'package:m_manager/ui/cubits_app/cubits_state.dart';
import 'package:m_manager/ui/screen/setting_page.dart';
import 'package:m_manager/generated/l10n.dart';
import 'package:m_manager/widgets_screen/loading_screen.dart';
import 'package:m_manager/app_db.dart';
import 'package:m_manager/firebase_store/expense_store.dart';
import 'package:m_manager/ui/screen/add_trans.dart';
import 'package:m_manager/ui/screen/histroy.dart';
import 'package:m_manager/ui/screen/spiltter/split_page.dart';

// ─── Theme Constants ──────────────────────────────────────────────────────────
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class MoneyManagerHomePage extends StatefulWidget {
  const MoneyManagerHomePage({super.key});

  @override
  State<MoneyManagerHomePage> createState() => _MoneyManagerHomePageState();
}

class _MoneyManagerHomePageState extends State<MoneyManagerHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fetchData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      appDb.storeUserId(userId);
      expenseStore.fetchExpenses();
      expenseStore.fetchIncome();
      _animCtrl.forward();
    } else {
      print('User is not logged in');
    }
  }

  void _exitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(S.of(context).confirmExit),
        content: Text(S.of(context).areYouSureYouWantToExit),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(S.of(context).cancel,
                style: const TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () => exit(0),
            child: Text(S.of(context).exit,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) _exitApp(context);
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: BlocBuilder<AddExpenseCubit, AddExpenseState>(
          builder: (context, state) {
            if (state is ExpenseFetching ||
                state is ExpenseAdding ||
                state is ExpenseLoading) {
              return const Loading(status: true);
            }

            return Observer(builder: (_) {
              final isLoading = expenseStore.isLoading;
              final balance = expenseStore.leftBalance;
              final income = expenseStore.totalIncome;
              final expenses = expenseStore.totalExpenses;
              final hasData = income > 0 || expenses > 0;

              return FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Balance Card ──────────────────────────────────
                        // Income & Expense shown ONLY here — not repeated below
                        Skeletonizer(
                          enabled: isLoading,
                          child: _BalanceCard(
                            balance: balance,
                            income: income,
                            expenses: expenses,
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // ── 2. Quick Actions ─────────────────────────────────
                        SectionHeader(title: "Quick Actions"),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            _ActionTile(
                              icon: Icons.receipt_long_rounded,
                              label: S.of(context).expenseSummary,
                              color: const Color(0xFF0EA5E9),
                              onTap: () =>
                                  Get.to(() => const ExpenseSummaryPage()),
                            ),
                            SizedBox(width: 12.w),
                            _ActionTile(
                              icon: Icons.call_split_rounded,
                              label: S.of(context).split,
                              color: const Color(0xFFF59E0B),
                              onTap: () =>
                                  Get.to(() => const SplitExpensePage()),
                            ),
                          ],
                        ),

                        SizedBox(height: 28.h),

                        // ── 3. Spending progress — only if data exists ────────
                        if (!isLoading && hasData) ...[
                          SectionHeader(title: "Spending Overview"),
                          SizedBox(height: 14.h),
                          _SpendingProgress(income: income, expenses: expenses),
                          SizedBox(height: 16.h),
                          _InsightCard(income: income, expenses: expenses),
                        ],

                        // ── 4. Empty state ────────────────────────────────────
                        if (!isLoading && !hasData) _EmptyState(),

                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const AddExpensePage()),
          backgroundColor: _purple,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("Add Transaction",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 8,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        S.of(context).moneyManager,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
          color: _purple,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
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
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_rounded, color: _purple),
            onPressed: () => Get.to(() => SettingsPage()),
          ),
        ),
      ],
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
// Income & Expenses live ONLY here — not duplicated anywhere else on the screen

class _BalanceCard extends StatelessWidget {
  final double balance, income, expenses;
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4DD9), Color(0xFF8B6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.45),
            blurRadius: 32,
            offset: const Offset(0, 14),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + optional warning chip
          Row(
            children: [
              const Text(
                "Total Balance Left",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              if (balance < 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orangeAccent, size: 13),
                      SizedBox(width: 4),
                      Text("Overspent",
                          style: TextStyle(
                              color: Colors.orangeAccent, fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 8.h),

          // Big balance
          Text(
            "₹ $balance",
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.2,
            ),
          ),

          SizedBox(height: 22.h),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          SizedBox(height: 18.h),

          // Income | Expenses — ONE source of truth on the home screen
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_up_rounded,
                          color: Color(0xFF4ADE80), size: 16),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Income",
                            style:
                                TextStyle(color: Colors.white60, fontSize: 11)),
                        Text("₹ $income",
                            style: const TextStyle(
                                color: Color(0xFF4ADE80),
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36.h,
                color: Colors.white.withOpacity(0.15),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Expenses",
                            style:
                                TextStyle(color: Colors.white60, fontSize: 11)),
                        Text("₹ $expenses",
                            style: const TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ],
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCA5A5).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_down_rounded,
                          color: Color(0xFFFCA5A5), size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Action Tile ──────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.13),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Spending Progress ────────────────────────────────────────────────────────

class _SpendingProgress extends StatelessWidget {
  final double income, expenses;
  const _SpendingProgress({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final ratio = income > 0 ? (expenses / income).clamp(0.0, 1.0) : 0.0;
    final pct = (ratio * 100).toStringAsFixed(0);
    final isOver = ratio > 0.8;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Budget Used",
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isOver ? _red.withOpacity(0.1) : _purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$pct%",
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: isOver ? _red : _purple,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Stack(
            children: [
              Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: _purpleSoft,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOver
                          ? [_red, Colors.orangeAccent]
                          : [_purple, _purpleLight],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹0",
                  style: TextStyle(fontSize: 11.sp, color: Colors.black38)),
              Text(
                isOver ? "⚠ Over budget!" : "of ₹$income",
                style: TextStyle(
                    fontSize: 11.sp, color: isOver ? _red : Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Insight Card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final double income, expenses;
  const _InsightCard({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final saved = income - expenses;
    final savePct = income > 0
        ? ((saved / income) * 100).clamp(0.0, 100.0).toStringAsFixed(0)
        : "0";
    final isGood = saved >= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isGood ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isGood ? _green.withOpacity(0.3) : _red.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGood ? _green.withOpacity(0.15) : _red.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGood ? Icons.savings_rounded : Icons.warning_amber_rounded,
              color: isGood ? _green : _red,
              size: 24,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGood ? "Great savings! 🎉" : "Overspending alert!",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isGood ? _green : _red,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  isGood
                      ? "You saved ₹$saved ($savePct% of income) this month."
                      : "You exceeded your income by ₹${saved.abs()}.",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18.h,
          margin: EdgeInsets.only(right: 10.w),
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _purple.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ],
            ),
            child:
                Lottie.asset('images/empty.json', height: 110.h, repeat: true),
          ),
          SizedBox(height: 20.h),
          Text(
            "No Transactions Yet",
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tap the button below to\nadd your first transaction",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.black38),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddExpensePage()),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text("Add Transaction",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              elevation: 6,
              shadowColor: _purple.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
