// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';
import 'package:m_manager/app_db.dart';
import '../utils/model.dart';

part 'expense_store.g.dart';

class ExpenseStore = _ExpenseStore with _$ExpenseStore;

abstract class _ExpenseStore with Store {
  // ── All expenses (raw, unfiltered) ─────────────────────────────────────────
  @observable
  ObservableList<Expense> expenses = ObservableList<Expense>();

  // ── Date-filtered expenses ─────────────────────────────────────────────────
  @observable
  ObservableList<Expense> filteredExpenses = ObservableList<Expense>();

  // ── Currently active filter date (null = no filter applied) ───────────────
  @observable
  DateTime? activeFilterDate;

  @observable
  bool isPasswordVisible = false;

  @observable
  double totalIncome = 0.0;

  @observable
  String? userId;

  @observable
  bool isLoading = true;

  // ── Whether the date-filtered fetch is running ─────────────────────────────
  @observable
  bool isFilterLoading = false;

  // ── Computed: total of ALL expenses ───────────────────────────────────────
  @computed
  double get totalExpenses =>
      expenses.fold(0.0, (total, e) => total + e.amount);

  // ── Computed: total of only filtered expenses ──────────────────────────────
  @computed
  double get filteredTotal =>
      filteredExpenses.fold(0.0, (total, e) => total + e.amount);

  @computed
  double get balance => totalIncome - totalExpenses;

  @computed
  double get leftBalance => totalIncome - totalExpenses;

  // ── Fetch ALL expenses from Firestore ──────────────────────────────────────
  @action
  Future<void> fetchExpenses() async {
    isLoading = true;
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        isLoading = false;
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final List<dynamic> expenseList = docSnapshot['expense'] ?? [];
        expenses
          ..clear()
          ..addAll(
            expenseList.map(
              (e) => Expense.fromMap(e as Map<String, dynamic>),
            ),
          );

        // If a filter date is active, re-apply it on the fresh data
        if (activeFilterDate != null) {
          _applyLocalFilter(activeFilterDate!);
        }
      } else {
        print("User document does not exist.");
      }
    } catch (error) {
      print("Error fetching expenses: $error");
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchExpensesByDate(DateTime date) async {
    activeFilterDate = date;
    isFilterLoading = true;

    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        isFilterLoading = false;
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final List<dynamic> expenseList = docSnapshot['expense'] ?? [];

        // Parse ALL expenses fresh (keeps `expenses` list up-to-date too)
        final allParsed = expenseList
            .map((e) => Expense.fromMap(e as Map<String, dynamic>))
            .toList();

        expenses
          ..clear()
          ..addAll(allParsed);

        // Now filter locally by the selected date
        _applyLocalFilter(date);

        print(
          "Fetched ${filteredExpenses.length} expense(s) for "
          "${date.day}/${date.month}/${date.year}",
        );
      } else {
        print("User document does not exist.");
        filteredExpenses.clear();
      }
    } catch (error) {
      print("Error fetching expenses by date: $error");
      filteredExpenses.clear();
    } finally {
      isFilterLoading = false;
    }
  }

  // ── Clear date filter — revert to showing all expenses ────────────────────
  @action
  void clearDateFilter() {
    activeFilterDate = null;
    filteredExpenses.clear();
    print("Date filter cleared. Showing all expenses.");
  }

  // ── Internal helper — filters `expenses` → `filteredExpenses` ─────────────
  @action
  void _applyLocalFilter(DateTime date) {
    filteredExpenses
      ..clear()
      ..addAll(
        expenses.where((expense) {
          final d = _toDateTime(expense.date);
          if (d == null) return false;
          return d.year == date.year &&
              d.month == date.month &&
              d.day == date.day;
        }),
      );
  }

  // ── Helper: normalise any date representation to DateTime? ────────────────
  DateTime? _toDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  // ── Fetch income ──────────────────────────────────────────────────────────
  @action
  Future<void> fetchIncome() async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        totalIncome = (docSnapshot['income'] ?? 0.0).toDouble();
        print("Fetched income: $totalIncome");
      } else {
        totalIncome = 0.0;
      }
    } catch (error) {
      print("Error fetching income: $error");
    }
  }

  // ── Add expense ───────────────────────────────────────────────────────────
  @action
  Future<void> addExpense(Expense expense) async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      final expenseId = FirebaseFirestore.instance.collection('users').doc().id;

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDoc.update({
        'expense': FieldValue.arrayUnion([expense.toMap()..['id'] = expenseId]),
      });

      final newExpense = Expense(
        id: expenseId,
        category: expense.category,
        amount: expense.amount,
        date: expense.date,
        time: expense.time,
      );

      expenses.add(newExpense);

      // If filter is active and this new expense matches the date → add it too
      if (activeFilterDate != null) {
        final d = _toDateTime(newExpense.date);
        if (d != null &&
            d.year == activeFilterDate!.year &&
            d.month == activeFilterDate!.month &&
            d.day == activeFilterDate!.day) {
          filteredExpenses.add(newExpense);
        }
      }

      await fetchExpenses();
      await fetchIncome();
      print("Added expense successfully.");
    } catch (error) {
      print("Error adding expense: $error");
    }
  }

  // ── Delete expense ────────────────────────────────────────────────────────
  @action
  Future<void> deleteExpense(String documentId) async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        final List<dynamic> currentExpenses = docSnapshot['expense'] ?? [];

        final expenseToDelete = currentExpenses.firstWhere(
          (e) => e['id'] == documentId,
          orElse: () => null,
        );

        if (expenseToDelete != null) {
          await userDoc.update({
            'expense': FieldValue.arrayRemove([expenseToDelete]),
          });

          expenses.removeWhere((e) => e.id == documentId);

          // Also remove from filtered list if present
          filteredExpenses.removeWhere((e) => e.id == documentId);

          print("Expense deleted successfully.");
        } else {
          print("Expense with ID $documentId not found.");
        }
      }
    } catch (error) {
      print("Error deleting expense: $error");
    }
  }

  // ── Update income ─────────────────────────────────────────────────────────
  @action
  Future<void> updateIncome(double newIncomeValue) async {
    try {
      final userId = await appDb.getUserId();
      if (userId == null) {
        print("User ID not found.");
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'income': newIncomeValue});

      totalIncome = newIncomeValue;
      print("Income updated to $newIncomeValue.");
    } catch (error) {
      print("Error updating income: $error");
    }
  }
}

var expenseStore = ExpenseStore();
