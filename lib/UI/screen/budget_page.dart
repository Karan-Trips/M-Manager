import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:m_manager/ui/cubits_app/cubits_app.dart';
import 'package:m_manager/utils/constants.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _orange = Color(0xFFFB923C);
const _bg = Color(0xFFF5F3FF);

class SetBudgetPage extends StatefulWidget {
  const SetBudgetPage({super.key});

  @override
  State<SetBudgetPage> createState() => _SetBudgetPageState();
}

class _SetBudgetPageState extends State<SetBudgetPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late BudgetCubit _budgetCubit;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _budgetCubit = BudgetCubit();
    _budgetCubit.fetchBudgets();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _budgetCubit,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          title: Text(
            "Set Budget",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder<BudgetCubit, Map<String, double>>(
            builder: (context, budgets) {
              final categories = AppConstants.defaultCategories;

              // Calculate total budget
              final totalBudget =
                  budgets.values.fold(0.0, (sum, amount) => sum + amount);

              return Column(
                children: [
                  // Budget Summary Card
                  _buildSummaryCard(totalBudget, budgets.length),

                  // Categories List
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          _buildSectionHeader(categories.length),
                          SizedBox(height: 16.h),
                          Expanded(
                            child: categories.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      final budget = budgets[category];
                                      return _buildBudgetCard(
                                        context,
                                        category,
                                        budget,
                                        index,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalBudget, int categoriesWithBudget) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_purple, _purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '₹${totalBudget.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  Icons.category,
                  '$categoriesWithBudget',
                  'Categories',
                ),
                Container(
                  width: 1,
                  height: 30.h,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  Icons.calendar_month,
                  'Monthly',
                  'Period',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category Budgets',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _purpleSoft,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count ${count == 1 ? "category" : "categories"}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _purple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    String category,
    double? budget,
    int index,
  ) {
    final isSet = budget != null && budget > 0;
    final percentage =
        isSet ? 1.0 : 0.0; // You can calculate actual spending vs budget here

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () =>
                _showBudgetDialog(context, _budgetCubit, category, budget),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Category Icon
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isSet
                                ? [_purple.withOpacity(0.1), _purpleSoft]
                                : [
                                    Colors.grey.withOpacity(0.1),
                                    Colors.grey.withOpacity(0.05)
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: isSet ? _purple : Colors.grey,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Category Name and Budget
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  size: 14.sp,
                                  color: isSet ? _purple : Colors.grey[500],
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  isSet ? budget.toStringAsFixed(2) : 'Not Set',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSet ? _purple : Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  ' / month',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit Button
                      Container(
                        decoration: BoxDecoration(
                          color: isSet ? _purpleSoft : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSet ? Icons.edit_outlined : Icons.add,
                            color: isSet ? _purple : Colors.grey[600],
                            size: 20.sp,
                          ),
                          onPressed: () => _showBudgetDialog(
                            context,
                            _budgetCubit,
                            category,
                            budget,
                          ),
                          tooltip: isSet ? 'Edit Budget' : 'Set Budget',
                        ),
                      ),
                    ],
                  ),

                  // Progress Bar (if budget is set)
                  if (isSet) ...[
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(percentage),
                        ),
                        minHeight: 6.h,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tap to edit budget',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          '${(percentage * 100).toInt()}% used',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _getProgressColor(percentage),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: _purpleSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64.sp,
              color: _purple,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Categories Available',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add categories to set budgets',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.7) {
      return _green;
    } else if (percentage < 0.9) {
      return _orange;
    } else {
      return _red;
    }
  }

  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();

    if (lowerCategory.contains('food') || lowerCategory.contains('meal')) {
      return Icons.restaurant;
    } else if (lowerCategory.contains('transport') ||
        lowerCategory.contains('travel')) {
      return Icons.directions_car;
    } else if (lowerCategory.contains('shopping') ||
        lowerCategory.contains('shop')) {
      return Icons.shopping_bag;
    } else if (lowerCategory.contains('entertainment') ||
        lowerCategory.contains('fun')) {
      return Icons.movie;
    } else if (lowerCategory.contains('health') ||
        lowerCategory.contains('medical')) {
      return Icons.local_hospital;
    } else if (lowerCategory.contains('education') ||
        lowerCategory.contains('study')) {
      return Icons.school;
    } else if (lowerCategory.contains('bill') ||
        lowerCategory.contains('utility')) {
      return Icons.receipt_long;
    } else if (lowerCategory.contains('home') ||
        lowerCategory.contains('house')) {
      return Icons.home;
    } else if (lowerCategory.contains('sport') ||
        lowerCategory.contains('gym')) {
      return Icons.fitness_center;
    } else if (lowerCategory.contains('cloth') ||
        lowerCategory.contains('fashion')) {
      return Icons.checkroom;
    } else {
      return Icons.label;
    }
  }

  void _showBudgetDialog(
    BuildContext context,
    BudgetCubit cubit,
    String category,
    double? currentBudget,
  ) {
    _budgetController.text = currentBudget?.toString() ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: _purpleSoft,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: _purple,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Budget',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Budget Amount',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _budgetController,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.currency_rupee, color: _purple),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: _purple, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: _red, width: 1),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: _purpleSoft.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: _purple,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Set a realistic monthly budget to track your spending',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _budgetController.clear();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final amount = double.tryParse(_budgetController.text) ?? 0;
                if (amount > 0) {
                  cubit.setBudget(category, amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Budget for $category set to ₹${amount.toStringAsFixed(2)}',
                      ),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                }
                Navigator.pop(dialogContext);
                _budgetController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );
  }
}
