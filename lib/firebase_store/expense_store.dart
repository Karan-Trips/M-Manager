// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';
import 'package:try1/app_db.dart';
import '../utils/model.dart';

part 'expense_store.g.dart';

class ExpenseStore = _ExpenseStore with _$ExpenseStore;

abstract class _ExpenseStore with Store {
  @observable
  ObservableList<Expense> expenses = ObservableList<Expense>();

  @observable
  bool isPasswordVisible = false;

  @observable
  double totalIncome = 0.0;

  @observable
  String? userId;

  @computed
  double get totalExpenses {
    return expenses.fold(0.0, (total, expense) => total + expense.amount);
  }

  @computed
  double get balance {
    return totalIncome - totalExpenses;
  }

  @computed
  double get leftBalance {
    return totalIncome - totalExpenses;
  }

  @observable
  bool isLoading = true;

  @action
  Future<void> fetchExpenses() async {
    isLoading = true;
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        List<dynamic> expenseList = docSnapshot['expense'] ?? [];
        expenses.clear();
        expenses.addAll(
          expenseList.map(
            (expense) => Expense.fromMap(expense as Map<String, dynamic>),
          ),
        );
        print("Fetched expenses successfully.");
        isLoading = false;
      } else {
        print("User document does not exist.");
        isLoading = false;
      }
    } catch (error) {
      print("Error fetching expenses: $error");
      isLoading = false;
    }
  }

  @action
  Future<void> fetchIncome() async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        totalIncome = docSnapshot['income'] ?? 0.0;
        print("Fetched income successfully: $totalIncome");
      } else {
        print("User document does not exist.");
        totalIncome = 0.0;
      }
    } catch (error) {
      print("Error fetching income: $error");
    }
  }

  @action
  Future<void> addExpense(Expense expense) async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      String expenseId =
          FirebaseFirestore.instance.collection('users').doc().id;

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDoc.update({
        'expense': FieldValue.arrayUnion([expense.toMap()..['id'] = expenseId]),
      });

      expenses.add(Expense(
        id: expenseId,
        category: expense.category,
        amount: expense.amount,
        date: expense.date,
        time: expense.time,
      ));

      print("Added expense successfully.");
    } catch (error) {
      print("Error adding expense: $error");
    }
  }

  @action
  Future<void> deleteExpense(String documentId) async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Retrieve the current expenses
      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        List<dynamic> currentExpenses = docSnapshot['expense'] ?? [];

        // Find the expense to delete by document ID
        final expenseToDelete = currentExpenses.firstWhere(
          (expense) => expense['id'] == documentId,
          orElse: () => null,
        );

        if (expenseToDelete != null) {
          // Remove the expense from Firestore
          await userDoc.update({
            'expense': FieldValue.arrayRemove([expenseToDelete]),
          });

          // Remove the expense from the local observable list
          expenses.removeWhere((expense) => expense.id == documentId);

          print("Expense deleted successfully.");
        } else {
          print("Expense with the given documentId not found.");
        }
      } else {
        print("User document does not exist.");
      }
    } catch (error) {
      print("Error deleting expense: $error");
    }
  }

  @action
  Future<void> updateIncome(double newIncomeValue) async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found. Please sign in again.");
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDoc.update({'income': newIncomeValue});
      totalIncome = newIncomeValue;

      print("Income updated successfully.");
    } catch (error) {
      print("Error updating income: $error");
    }
  }
}

var expenseStore = ExpenseStore();
