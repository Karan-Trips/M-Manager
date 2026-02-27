import 'package:m_manager/utils/model.dart';

abstract class AddExpenseState {}

class AddExpenseInitial extends AddExpenseState {}

/// 🔄 Generic loading state (could be used globally)
class ExpenseLoading extends AddExpenseState {}

/// 🔄 Loading state specifically for fetching details
class ExpenseFetching extends AddExpenseState {}

/// 🔄 Loading state specifically for adding an expense
class ExpenseAdding extends AddExpenseState {}

/// ✅ Success and failure states
class ExpenseSuccess extends AddExpenseState {
  final String message;
  ExpenseSuccess(this.message);
}

class ExpenseFailure extends AddExpenseState {
  final String error;
  ExpenseFailure(this.error);
}

/// 📦 Data states
class ExpenseFetched extends AddExpenseState {
  final List<Expense> expenses;
  ExpenseFetched(this.expenses);
}

class IncomeFetched extends AddExpenseState {
  final double totalIncome;
  IncomeFetched(this.totalIncome);
}

/// 🧩 UI/Field-related states
class AddExpenseCategoryUpdated extends AddExpenseState {
  final String category;
  AddExpenseCategoryUpdated(this.category);
}

class AddExpenseIncomeFieldToggled extends AddExpenseState {
  final bool isVisible;
  AddExpenseIncomeFieldToggled(this.isVisible);
}

class AddExpenseCategoryAdded extends AddExpenseState {
  final List<String> categories;
  AddExpenseCategoryAdded(this.categories);
}

class AddExpenseCategoryRemoved extends AddExpenseState {
  final List<String> categories;
  AddExpenseCategoryRemoved(this.categories);
}
