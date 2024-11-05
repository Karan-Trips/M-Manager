// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ExpenseStore on _ExpenseStore, Store {
  Computed<double>? _$totalExpensesComputed;

  @override
  double get totalExpenses =>
      (_$totalExpensesComputed ??= Computed<double>(() => super.totalExpenses,
              name: '_ExpenseStore.totalExpenses'))
          .value;
  Computed<double>? _$balanceComputed;

  @override
  double get balance => (_$balanceComputed ??=
          Computed<double>(() => super.balance, name: '_ExpenseStore.balance'))
      .value;
  Computed<double>? _$leftBalanceComputed;

  @override
  double get leftBalance =>
      (_$leftBalanceComputed ??= Computed<double>(() => super.leftBalance,
              name: '_ExpenseStore.leftBalance'))
          .value;

  late final _$expensesAtom =
      Atom(name: '_ExpenseStore.expenses', context: context);

  @override
  ObservableList<Expense> get expenses {
    _$expensesAtom.reportRead();
    return super.expenses;
  }

  @override
  set expenses(ObservableList<Expense> value) {
    _$expensesAtom.reportWrite(value, super.expenses, () {
      super.expenses = value;
    });
  }

  late final _$isPasswordVisibleAtom =
      Atom(name: '_ExpenseStore.isPasswordVisible', context: context);

  @override
  bool get isPasswordVisible {
    _$isPasswordVisibleAtom.reportRead();
    return super.isPasswordVisible;
  }

  @override
  set isPasswordVisible(bool value) {
    _$isPasswordVisibleAtom.reportWrite(value, super.isPasswordVisible, () {
      super.isPasswordVisible = value;
    });
  }

  late final _$totalIncomeAtom =
      Atom(name: '_ExpenseStore.totalIncome', context: context);

  @override
  double get totalIncome {
    _$totalIncomeAtom.reportRead();
    return super.totalIncome;
  }

  @override
  set totalIncome(double value) {
    _$totalIncomeAtom.reportWrite(value, super.totalIncome, () {
      super.totalIncome = value;
    });
  }

  late final _$userIdAtom =
      Atom(name: '_ExpenseStore.userId', context: context);

  @override
  String? get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(String? value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ExpenseStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$fetchExpensesAsyncAction =
      AsyncAction('_ExpenseStore.fetchExpenses', context: context);

  @override
  Future<void> fetchExpenses() {
    return _$fetchExpensesAsyncAction.run(() => super.fetchExpenses());
  }

  late final _$fetchIncomeAsyncAction =
      AsyncAction('_ExpenseStore.fetchIncome', context: context);

  @override
  Future<void> fetchIncome() {
    return _$fetchIncomeAsyncAction.run(() => super.fetchIncome());
  }

  late final _$addExpenseAsyncAction =
      AsyncAction('_ExpenseStore.addExpense', context: context);

  @override
  Future<void> addExpense(Expense expense) {
    return _$addExpenseAsyncAction.run(() => super.addExpense(expense));
  }

  late final _$deleteExpenseAsyncAction =
      AsyncAction('_ExpenseStore.deleteExpense', context: context);

  @override
  Future<void> deleteExpense(String documentId) {
    return _$deleteExpenseAsyncAction
        .run(() => super.deleteExpense(documentId));
  }

  late final _$updateIncomeAsyncAction =
      AsyncAction('_ExpenseStore.updateIncome', context: context);

  @override
  Future<void> updateIncome(double newIncomeValue) {
    return _$updateIncomeAsyncAction
        .run(() => super.updateIncome(newIncomeValue));
  }

  @override
  String toString() {
    return '''
expenses: ${expenses},
isPasswordVisible: ${isPasswordVisible},
totalIncome: ${totalIncome},
userId: ${userId},
isLoading: ${isLoading},
totalExpenses: ${totalExpenses},
balance: ${balance},
leftBalance: ${leftBalance}
    ''';
  }
}
