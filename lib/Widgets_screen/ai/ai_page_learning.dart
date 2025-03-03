import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  File? _image;
  String _extractedText = "";
  bool _isLoading = false;
  final List<String> priceIndicators = ["total", "amount", "rs", "₹"];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isLoading = true;
    });

    await _scanText();
    setState(() => _isLoading = false);
  }

  Future<void> _scanText() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    setState(() {
      _extractedText = recognizedText.text;
    });
  }

  List<double> _extractPrices() {
    List<double> prices = [];
    List<String> words = _extractedText.split(RegExp(r'\s+'));

    for (int i = 0; i < words.length; i++) {
      String word = words[i].replaceAll(RegExp(r'[^0-9₹.]'), "");

      // Ensure i > 0 before checking the previous word
      if (word.contains("₹") ||
          (i > 0 && priceIndicators.contains(words[i - 1].toLowerCase()))) {
        String amount = word.replaceAll("₹", "");
        double? price = double.tryParse(amount);
        if (price != null) prices.add(price);
      }
    }
    return prices;
  }

  @override
  Widget build(BuildContext context) {
    List<double> prices = _extractPrices();

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Receipt")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              if (_image != null) Image.file(_image!, height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ],
              ),
              if (_isLoading) const CircularProgressIndicator(),
              if (_extractedText.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text("Extracted Text:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  child:
                      Text(_extractedText, style: const TextStyle(fontSize: 14)),
                ),
                if (prices.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("Detected Prices:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prices
                        .map((e) => Text("₹${e.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16)))
                        .toList(),
                  ),
                ]
              ],
            ],
          ),
        ),
      ),
    );
  }
}
