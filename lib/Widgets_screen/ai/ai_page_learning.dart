// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

// class ScanReceiptPage extends StatefulWidget {
//   const ScanReceiptPage({super.key});

//   @override
//   State<ScanReceiptPage> createState() => _ScanReceiptPageState();
// }

// class _ScanReceiptPageState extends State<ScanReceiptPage> {
//   File? _image;
//   String _extractedText = "";
//   bool _isLoading = false;
//   final ImagePicker _picker = ImagePicker();
//   final List<String> categories = [
//     "food",
//     "fast food",
//     "grocery",
//     "rent",
//     "emi",
//     "traveling",
//     "fueling"
//   ];

//   // Pick image from gallery or camera
//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _isLoading = true;
//       });
//       await _scanText();
//       setState(() => _isLoading = false);
//     }
//   }

//   // Scan text using ML Kit
//   Future<void> _scanText() async {
//     if (_image == null) return;

//     final inputImage = InputImage.fromFile(_image!);
//     final textRecognizer = TextRecognizer();
//     final RecognizedText recognizedText =
//         await textRecognizer.processImage(inputImage);
//     await textRecognizer.close();

//     setState(() => _extractedText = recognizedText.text);
//   }

//   // Extract category and amount
//   Map<String, double> _extractExpenses() {
//     Map<String, double> detectedExpenses = {};
//     List<String> words = _extractedText.toLowerCase().split(RegExp(r"\s+"));

//     for (int i = 0; i < words.length; i++) {
//       if (categories.contains(words[i])) {
//         double? amount = _findAmount(words, i);
//         if (amount != null) detectedExpenses[words[i]] = amount;
//       }
//     }
//     return detectedExpenses;
//   }

//   // Find the amount near a category
//   double? _findAmount(List<String> words, int index) {
//     for (int i = index + 1; i < words.length; i++) {
//       String word = words[i].replaceAll(RegExp(r"[^\d.]"), "");
//       if (word.isNotEmpty && RegExp(r"^\d+(\.\d+)?").hasMatch(word)) {
//         return double.tryParse(word);
//       }
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     Map<String, double> expenses = _extractExpenses();

//     return Scaffold(
//       appBar: AppBar(title: Text("Scan Receipt")),
//       body: Padding(
//         padding: EdgeInsets.all(10),
//         child: Column(
//           children: [
//             if (_image != null) Image.file(_image!, height: 200),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   icon: Icon(Icons.camera_alt),
//                   label: Text("Camera"),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: Icon(Icons.photo),
//                   label: Text("Gallery"),
//                 ),
//               ],
//             ),
//             if (_isLoading) CircularProgressIndicator(),
//             if (_extractedText.isNotEmpty)
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Extracted Text:",
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text(_extractedText),
//                       SizedBox(height: 10),
//                       if (expenses.isNotEmpty) ...[
//                         Text("Detected Expenses:",
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         ...expenses.entries.map((e) =>
//                             Text("${e.key}: ₹${e.value.toStringAsFixed(2)}")),
//                       ] else
//                         Text("No expenses detected."),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
