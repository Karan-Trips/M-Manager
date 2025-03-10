import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:try1/UI/cubits_app/cubits_state.dart';
import 'package:try1/app_db.dart';
import 'package:try1/utils/model.dart';

import '../../generated/l10n.dart';

class AddExpenseCubit extends Cubit<AddExpenseState> {
  AddExpenseCubit() : super(AddExpenseInitial());

  final TextEditingController amountController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  String selectedCategory = 'Groceries';
  bool showIncomeTextField = false;

  List<String> categories = [
    'Groceries',
    'Fast-Food',
    'Ghumne',
    'Food',
    'Medicine',
    'Office',
    'EMI',
  ];

  void updateCategory(String? category) {
    if (category != null) {
      selectedCategory = category;
      emit(AddExpenseCategoryUpdated(category));
    }
  }

  void addCategory(String newCategory) {
    print("Before: $categories");
    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
      categories = List.from(categories)..add(newCategory);
      emit(AddExpenseCategoryAdded(List.from(categories)));
    }
    print("After: $categories");
  }

  void removeCategory(String category) {
    if (categories.contains(category)) {
      categories.remove(category);
      emit(AddExpenseCategoryRemoved(categories));
    }
  }

  void toggleIncomeField() {
    showIncomeTextField = !showIncomeTextField;
    emit(AddExpenseIncomeFieldToggled(showIncomeTextField));
  }

  String? validateAmount(String? value) {
    if (value == null ||
        double.tryParse(value) == null ||
        double.parse(value) <= 0) {
      return S.current.pleaseEnterAValidAmount;
    } else if (value.length > 8) {
      return S.current.amountIsTooLargeToHandle;
    }
    return null;
  }

  String? validateIncome(String? value) {
    if (value == null ||
        double.tryParse(value) == null ||
        double.parse(value) <= 0) {
      return S.current.pleaseEnterAValidIncome;
    } else if (value.length > 8) {
      return S.current.amountIsTooLargeToHandle;
    }
    return null;
  }

  Future<void> fetchExpenses() async {
    emit(ExpenseLoading());
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        emit(ExpenseFailure(S.current.userIdNotFound));
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        List<dynamic> expenseList = docSnapshot['expense'] ?? [];
        List<Expense> expenses = expenseList
            .map((expense) => Expense.fromMap(expense as Map<String, dynamic>))
            .toList();
        emit(ExpenseFetched(expenses));
      } else {
        emit(ExpenseFailure(S.current.userDocumentDoesNotExist));
      }
    } catch (error) {
      emit(ExpenseFailure(S.current.errorFetchingExpensesError));
    }
  }

  Future<void> fetchIncome() async {
    emit(ExpenseLoading());
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        emit(ExpenseFailure(S.current.userIdNotFound));
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        double totalIncome = docSnapshot['income'] ?? 0.0;
        emit(IncomeFetched(totalIncome));
      } else {
        emit(ExpenseFailure(S.current.userDocumentDoesNotExist));
      }
    } catch (error) {
      emit(ExpenseFailure(S.current.errorFetchingIncomeError));
    }
  }

  Future<void> saveExpense() async {
    if (validateAmount(amountController.text) == null) {
      emit(ExpenseLoading());
      try {
        final userId = await appDb.getUserId();
        if (userId == null) {
          emit(ExpenseFailure(S.current.userIdNotFound));
          return;
        }

        double amount = double.parse(amountController.text);
        String expenseId =
            FirebaseFirestore.instance.collection('expenses').doc().id;
        final expense = Expense(
          id: expenseId,
          date: DateTime.now(),
          category: selectedCategory,
          amount: amount,
          time: DateFormat('HH:mm').format(DateTime.now()),
        );

        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(userId);

        await userDoc.update({
          'expense': FieldValue.arrayUnion([expense.toMap()]),
        });

        emit(ExpenseSuccess(S.current.transactionSaved));
      } catch (e) {
        emit(ExpenseFailure(S.current.failedToSaveExpenseEtostring));
      }
    } else {
      emit(ExpenseFailure(S.current.invalidInputForAmount));
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    emit(ExpenseLoading());
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        emit(ExpenseFailure(S.current.userIdNotFound));
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        List<dynamic> currentExpenses = docSnapshot['expense'] ?? [];

        final expenseToDelete = currentExpenses.firstWhere(
          (expense) => expense['id'] == expenseId,
          orElse: () => null,
        );

        if (expenseToDelete != null) {
          await userDoc.update({
            'expense': FieldValue.arrayRemove([expenseToDelete]),
          });
          emit(ExpenseSuccess(S.current.expenseDeletedSuccessfully));
        } else {
          emit(ExpenseFailure(S.current.expenseWithTheGivenIdNotFound));
        }
      } else {
        emit(ExpenseFailure(S.current.userDocumentDoesNotExist));
      }
    } catch (error) {
      emit(ExpenseFailure(S.current.errorDeletingExpenseError));
    }
  }

  Future<void> updateIncome() async {
    if (validateIncome(incomeController.text) == null) {
      emit(ExpenseLoading());
      try {
        final userId = await appDb.getUserId();
        if (userId == null) {
          emit(ExpenseFailure(S.current.userIdNotFoundPleaseSignInAgain));
          return;
        }

        double newIncomeValue = double.parse(incomeController.text);

        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(userId);

        await userDoc.update({'income': newIncomeValue});
        emit(ExpenseSuccess(S.current.incomeValueUpdatedSuccessfully));
        incomeController.clear();
      } catch (e) {
        emit(ExpenseFailure(S.current.failedToUpdateIncomeEtostring));
      }
    } else {
      emit(ExpenseFailure(S.current.invalidInputForIncome));
    }
  }
}

class BudgetCubit extends Cubit<Map<String, double>> {
  BudgetCubit() : super({});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> fetchBudgets() async {
    if (_userId == null) {
      print("❌ User not logged in!");
      return;
    }

    try {
      print("🔍 Fetching budgets for User ID: $_userId");

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets')
          .get();

      final budgetData = <String, double>{};
      for (var doc in snapshot.docs) {
        budgetData[doc.id] = (doc.data()['amount'] as num).toDouble();
      }

      print("✅ Fetched budgets: $budgetData");
      emit(budgetData);
    } catch (e) {
      print("❌ Error fetching budgets: $e");
    }
  }

  Future<void> setBudget(String category, double amount) async {
    if (_userId == null) {
      print("❌ Cannot set budget, user not logged in!");
      return;
    }

    try {
      print("📝 Setting budget for $category: ₹$amount");

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets')
          .doc(category)
          .set({'amount': amount});

      final updatedBudgets = Map<String, double>.from(state);
      updatedBudgets[category] = amount;
      emit(updatedBudgets);

      print("✅ Budget updated: $updatedBudgets");
    } catch (e) {
      print("❌ Error setting budget: $e");
    }
  }

  double getBudget(String category) => state[category] ?? 0.0;
}
