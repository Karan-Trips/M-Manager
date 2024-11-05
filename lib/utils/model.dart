import 'package:intl/intl.dart';

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String time;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.time,
  });

  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      id: data['id'],
      category: data['category'],
      amount: data['amount'],
      date: DateTime.parse(data['date']),
      time: data['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'time': time,
    };
  }

  String getFormattedDate() {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String getFormattedTime() {
    return DateFormat('hh:mm a').format(DateTime.parse('1970-01-01 $time'));
  }
}
