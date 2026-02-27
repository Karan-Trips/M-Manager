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
  Computed<double>? _$filteredTotalComputed;

  @override
  double get filteredTotal =>
      (_$filteredTotalComputed ??= Computed<double>(() => super.filteredTotal,
              name: '_ExpenseStore.filteredTotal'))
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

  late final _$filteredExpensesAtom =
      Atom(name: '_ExpenseStore.filteredExpenses', context: context);

  @override
  ObservableList<Expense> get filteredExpenses {
    _$filteredExpensesAtom.reportRead();
    return super.filteredExpenses;
  }

  @override
  set filteredExpenses(ObservableList<Expense> value) {
    _$filteredExpensesAtom.reportWrite(value, super.filteredExpenses, () {
      super.filteredExpenses = value;
    });
  }

  late final _$activeFilterDateAtom =
      Atom(name: '_ExpenseStore.activeFilterDate', context: context);

  @override
  DateTime? get activeFilterDate {
    _$activeFilterDateAtom.reportRead();
    return super.activeFilterDate;
  }

  @override
  set activeFilterDate(DateTime? value) {
    _$activeFilterDateAtom.reportWrite(value, super.activeFilterDate, () {
      super.activeFilterDate = value;
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

  late final _$isFilterLoadingAtom =
      Atom(name: '_ExpenseStore.isFilterLoading', context: context);

  @override
  bool get isFilterLoading {
    _$isFilterLoadingAtom.reportRead();
    return super.isFilterLoading;
  }

  @override
  set isFilterLoading(bool value) {
    _$isFilterLoadingAtom.reportWrite(value, super.isFilterLoading, () {
      super.isFilterLoading = value;
    });
  }

  late final _$fetchExpensesAsyncAction =
      AsyncAction('_ExpenseStore.fetchExpenses', context: context);

  @override
  Future<void> fetchExpenses() {
    return _$fetchExpensesAsyncAction.run(() => super.fetchExpenses());
  }

  late final _$fetchExpensesByDateAsyncAction =
      AsyncAction('_ExpenseStore.fetchExpensesByDate', context: context);

  @override
  Future<void> fetchExpensesByDate(DateTime date) {
    return _$fetchExpensesByDateAsyncAction
        .run(() => super.fetchExpensesByDate(date));
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

  late final _$_ExpenseStoreActionController =
      ActionController(name: '_ExpenseStore', context: context);

  @override
  void clearDateFilter() {
    final _$actionInfo = _$_ExpenseStoreActionController.startAction(
        name: '_ExpenseStore.clearDateFilter');
    try {
      return super.clearDateFilter();
    } finally {
      _$_ExpenseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _applyLocalFilter(DateTime date) {
    final _$actionInfo = _$_ExpenseStoreActionController.startAction(
        name: '_ExpenseStore._applyLocalFilter');
    try {
      return super._applyLocalFilter(date);
    } finally {
      _$_ExpenseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
expenses: ${expenses},
filteredExpenses: ${filteredExpenses},
activeFilterDate: ${activeFilterDate},
isPasswordVisible: ${isPasswordVisible},
totalIncome: ${totalIncome},
userId: ${userId},
isLoading: ${isLoading},
isFilterLoading: ${isFilterLoading},
totalExpenses: ${totalExpenses},
filteredTotal: ${filteredTotal},
balance: ${balance},
leftBalance: ${leftBalance}
    ''';
  }
}
