import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:m_manager/ui/cubits_app/cubits_app.dart';
import 'package:m_manager/ui/cubits_app/cubits_state.dart';

import '../../generated/l10n.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _categoryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_formKey.currentState?.validate() ?? false) {
      String newCategory = _categoryController.text.trim();
      if (newCategory.isNotEmpty) {
        context.read<AddExpenseCubit>().addCategory(newCategory);
        _categoryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "$newCategory" added successfully'),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  void _editCategory(String oldCategory) {
    _categoryController.text = oldCategory;
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
                Icons.edit,
                color: _purple,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              S.of(context).editCategory,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _categoryController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Category Name',
            prefixIcon: Icon(Icons.category, color: _purple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: _purple, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _categoryController.clear();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String newCategory = _categoryController.text.trim();
              if (newCategory.isNotEmpty) {
                context.read<AddExpenseCubit>().removeCategory(oldCategory);
                context.read<AddExpenseCubit>().addCategory(newCategory);
                Navigator.pop(dialogContext);
                _categoryController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Category updated successfully'),
                    backgroundColor: _green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String category) {
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
                color: _red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: _red,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Delete Category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$category"? This action cannot be undone.',
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AddExpenseCubit>().removeCategory(category);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "$category" deleted'),
                  backgroundColor: _red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        title: Text(
          S.of(context).manageCategories,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Category Card
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: _purpleSoft,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 20.sp,
                              color: _purple,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Add New Category',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: InputDecoration(
                                labelText: S.of(context).categoryName,
                                hintText: 'e.g., Food, Transport, Shopping',
                                prefixIcon:
                                    Icon(Icons.category, color: _purple),
                                filled: true,
                                fillColor: _bg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: _purple,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: _red,
                                    width: 1,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a category name';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _addCategory(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            height: 56.h,
                            width: 56.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_purple, _purpleLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: _purple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                              onPressed: _addCategory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Categories List Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: BlocBuilder<AddExpenseCubit, AddExpenseState>(
                  builder: (context, state) {
                    var categories =
                        context.watch<AddExpenseCubit>().categories;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Categories',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _purpleSoft,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${categories.length} ${categories.length == 1 ? "category" : "categories"}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _purple,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              // Categories List
              Expanded(
                child: BlocBuilder<AddExpenseCubit, AddExpenseState>(
                  builder: (context, state) {
                    var categories =
                        context.watch<AddExpenseCubit>().categories;

                    if (categories.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(categories[index], index);
                      },
                    );
                  },
                ),
              ),
            ],
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
              Icons.category_outlined,
              size: 64.sp,
              color: _purple,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Categories Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first category to get started',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
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
            onTap: () => _editCategory(category),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_purple.withOpacity(0.1), _purpleSoft],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _purple,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Category Name
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
                        SizedBox(height: 4.h),
                        Text(
                          'Tap to edit',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      Container(
                        decoration: BoxDecoration(
                          color: _purpleSoft,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: _purple,
                            size: 20.sp,
                          ),
                          onPressed: () => _editCategory(category),
                          tooltip: 'Edit',
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Delete Button
                      Container(
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: _red,
                            size: 20.sp,
                          ),
                          onPressed: () => _deleteCategory(category),
                          tooltip: 'Delete',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();

    // Map common categories to icons
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
}
