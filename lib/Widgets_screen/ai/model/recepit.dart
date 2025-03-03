import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class ExpenseModel {
  final Map<String, double> categoryExpenses;
  final double totalAmount;

  ExpenseModel({required this.categoryExpenses, required this.totalAmount});

  @override
  String toString() {
    return "Expenses: $categoryExpenses, Total: $totalAmount";
  }
}

class ReceiptData {
  Map<String, double> items = {}; // Stores items and their prices
  double subtotal = 0.0;
  double tax = 0.0;
  double total = 0.0;
}

Future<ReceiptData> extractPricesWithLabels(String text) async {
  final entityExtractor =
      EntityExtractor(language: EntityExtractorLanguage.english);
  final entities = await entityExtractor.annotateText(text);
  await entityExtractor.close();

  ReceiptData receiptData = ReceiptData();
  List<String> words = text.split(RegExp(r"\s+"));

  for (int i = 0; i < words.length; i++) {
    String word = words[i].toLowerCase();

    if (["total", "subtotal", "grand total", "amount paid"].contains(word)) {
      double? amount = _findAmount(words, i);
      if (amount != null) {
        if (word.contains("subtotal")) {
          receiptData.subtotal = amount;
        } else if (word.contains("tax")) {
          receiptData.tax = amount;
        } else {
          receiptData.total = amount;
        }
      }
    } else {
      // Check if the word before it could be an item name
      double? amount = _findAmount(words, i);
      if (amount != null && i > 0) {
        String itemName = words[i - 1]; // Previous word as item name
        receiptData.items[itemName] = amount;
      }
    }
  }

  return receiptData;
}

// Helper function to find a number after a word
double? _findAmount(List<String> words, int index) {
  for (int i = index + 1; i < words.length; i++) {
    String num = words[i].replaceAll(RegExp(r"[^\d.]"), "");
    if (num.isNotEmpty && RegExp(r"^\d+(\.\d+)?$").hasMatch(num)) {
      return double.tryParse(num);
    }
  }
  return null;
}
