import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:try1/utils/model.dart';

class ReceiptPDF {
  static Future<Uint8List> generateReceiptAsBytes({
    required String title,
    required String date,
    required List<Expense> expenses,
    required double totalAmount,
  }) async {
    final pdf = pw.Document();
    final fontRegular = pw.Font.ttf(
      await rootBundle.load("images/fonts/NotoSans-Italic.ttf"),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(fontSize: 24, font: fontRegular)),
              pw.SizedBox(height: 10),
              pw.Text("Date: $date",
                  style: pw.TextStyle(fontSize: 16, font: fontRegular)),
              pw.Divider(),
              pw.Text("Expenses:",
                  style: pw.TextStyle(fontSize: 18, font: fontRegular)),
              ...expenses.expand((e) => [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("• ${e.category}",
                              style: pw.TextStyle(font: fontRegular)),
                          pw.Text("₹${e.amount.toStringAsFixed(2)}",
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 5),
                  ]),
              pw.Divider(),
              pw.Text("Total: ₹${totalAmount.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      font: fontRegular)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
