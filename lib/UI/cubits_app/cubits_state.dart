import 'package:try1/utils/model.dart';

abstract class AddExpenseState {}

class AddExpenseInitial extends AddExpenseState {}

class ExpenseLoading extends AddExpenseState {}

class ExpenseSuccess extends AddExpenseState {
  final String message;
  ExpenseSuccess(this.message);
}

class ExpenseFailure extends AddExpenseState {
  final String error;
  ExpenseFailure(this.error);
}

class ExpenseFetched extends AddExpenseState {
  final List<Expense> expenses;
  ExpenseFetched(this.expenses);
}

class IncomeFetched extends AddExpenseState {
  final double totalIncome;
  IncomeFetched(this.totalIncome);
}

class AddExpenseCategoryUpdated extends AddExpenseState {
  final String category;
  AddExpenseCategoryUpdated(this.category);
}

class AddExpenseIncomeFieldToggled extends AddExpenseState {
  final bool isVisible;
  AddExpenseIncomeFieldToggled(this.isVisible);
}
