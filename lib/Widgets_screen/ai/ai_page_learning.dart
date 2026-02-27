import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../generated/l10n.dart';

// Theme Colors
const _purple = Color(0xFF6A5AE0);
const _purpleLight = Color(0xFF8F7CFF);
const _purpleSoft = Color(0xFFF0EEFF);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _bg = Color(0xFFF5F3FF);

// Data Models
class ReceiptData {
  final String merchantName;
  final String? date;
  final double? subtotal;
  final double? tax;
  final double? total;
  final List<ReceiptItem> items;

  ReceiptData({
    required this.merchantName,
    this.date,
    this.subtotal,
    this.tax,
    this.total,
    this.items = const [],
  });

  ReceiptData copyWith({
    String? merchantName,
    String? date,
    double? subtotal,
    double? tax,
    double? total,
    List<ReceiptItem>? items,
  }) {
    return ReceiptData(
      merchantName: merchantName ?? this.merchantName,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      items: items ?? this.items,
    );
  }
}

class ReceiptItem {
  final String name;
  final double price;

  ReceiptItem({required this.name, required this.price});
}

// Receipt State
class ReceiptState {
  final String extractedText;
  final ReceiptData? receiptData;
  final bool isProcessing;
  final File? scannedImage;
  final String? errorMessage;

  ReceiptState({
    this.extractedText = '',
    this.receiptData,
    this.isProcessing = false,
    this.scannedImage,
    this.errorMessage,
  });

  ReceiptState copyWith({
    String? extractedText,
    ReceiptData? receiptData,
    bool? isProcessing,
    File? scannedImage,
    String? errorMessage,
    bool clearReceiptData = false,
    bool clearScannedImage = false,
    bool clearError = false,
  }) {
    return ReceiptState(
      extractedText: extractedText ?? this.extractedText,
      receiptData: clearReceiptData ? null : (receiptData ?? this.receiptData),
      isProcessing: isProcessing ?? this.isProcessing,
      scannedImage:
          clearScannedImage ? null : (scannedImage ?? this.scannedImage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Receipt Notifier
class ReceiptNotifier extends StateNotifier<ReceiptState> {
  ReceiptNotifier() : super(ReceiptState());

  final ImagePicker _picker = ImagePicker();

  /// Pick an image from a source
  Future<File?> _pickerImage({required ImageSource source}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Allow crop an image file
  Future<CroppedFile?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedfile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Receipt',
          toolbarColor: _purple,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: _purple,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
      ],
    );

    return croppedfile;
  }

  /// Create an instance from TextRecognizer and extract text from image
  Future<String> _recognizeTextFromImage({required String imgPath}) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final image = InputImage.fromFile(File(imgPath));
    final recognized = await textRecognizer.processImage(image);
    await textRecognizer.close();
    return recognized.text;
  }

  /// Parse extracted text to find receipt details
  ReceiptData _parseReceiptData(String text) {
    final lines = text.split('\n');

    // Initialize variables
    String? merchantName;
    String? date;
    double? subtotal;
    double? tax;
    double? total;
    List<ReceiptItem> items = [];

    // Patterns for matching
    final totalPattern =
        RegExp(r'total[:\s]*\$?(\d+\.?\d*)', caseSensitive: false);
    final subtotalPattern =
        RegExp(r'sub[- ]?total[:\s]*\$?(\d+\.?\d*)', caseSensitive: false);
    final taxPattern = RegExp(r'tax[:\s]*\$?(\d+\.?\d*)', caseSensitive: false);
    final datePattern = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
    final pricePattern = RegExp(r'\$?(\d+\.\d{2})');

    // Try to get merchant name (usually first non-empty line)
    for (var line in lines) {
      if (line.trim().isNotEmpty && merchantName == null) {
        merchantName = line.trim();
        break;
      }
    }

    // Extract date
    for (var line in lines) {
      final dateMatch = datePattern.firstMatch(line);
      if (dateMatch != null) {
        date = dateMatch.group(1);
        break;
      }
    }

    // Extract financial values
    for (var line in lines) {
      final lowerLine = line.toLowerCase();

      // Check for total
      final totalMatch = totalPattern.firstMatch(line);
      if (totalMatch != null && total == null) {
        total = double.tryParse(totalMatch.group(1)!);
      }

      // Check for subtotal
      final subtotalMatch = subtotalPattern.firstMatch(line);
      if (subtotalMatch != null && subtotal == null) {
        subtotal = double.tryParse(subtotalMatch.group(1)!);
      }

      // Check for tax
      final taxMatch = taxPattern.firstMatch(line);
      if (taxMatch != null && tax == null) {
        tax = double.tryParse(taxMatch.group(1)!);
      }

      // Try to extract items (lines with prices that aren't total/subtotal/tax)
      if (!lowerLine.contains('total') &&
          !lowerLine.contains('tax') &&
          !lowerLine.contains('change') &&
          !lowerLine.contains('card') &&
          line.trim().isNotEmpty) {
        final priceMatch = pricePattern.firstMatch(line);
        if (priceMatch != null) {
          final price = double.tryParse(priceMatch.group(1)!);
          if (price != null && price > 0) {
            // Get item name (text before price)
            final itemName =
                line.substring(0, line.indexOf(priceMatch.group(0)!)).trim();
            if (itemName.isNotEmpty && itemName.length > 2) {
              items.add(ReceiptItem(name: itemName, price: price));
            }
          }
        }
      }
    }

    return ReceiptData(
      merchantName: merchantName ?? 'Unknown Merchant',
      date: date,
      subtotal: subtotal,
      tax: tax,
      total: total,
      items: items,
    );
  }

  /// Process image and extract receipt data
  Future<void> processImageExtractText({
    required ImageSource imageSource,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final imageFile = await _pickerImage(source: imageSource);
      if (imageFile == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      final croppedImage = await _cropImage(imageFile: imageFile);
      if (croppedImage == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      final recognizedText = await _recognizeTextFromImage(
        imgPath: croppedImage.path,
      );

      final receiptData = _parseReceiptData(recognizedText);

      state = state.copyWith(
        extractedText: recognizedText,
        receiptData: receiptData,
        scannedImage: File(croppedImage.path),
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Error processing image: ${e.toString()}',
      );
    }
  }

  /// Reset all data
  void resetData() {
    state = ReceiptState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider
final receiptProvider = StateNotifierProvider<ReceiptNotifier, ReceiptState>(
  (ref) => ReceiptNotifier(),
);

// Receipt Page Widget
class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key});

  /// Copy text to clipboard
  void _copyToClipBoard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).copiedToClipboard),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptState = ref.watch(receiptProvider);
    final receiptNotifier = ref.read(receiptProvider.notifier);

    // Show error message if any
    if (receiptState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(receiptState.errorMessage!),
            backgroundColor: _red,
          ),
        );
        receiptNotifier.clearError();
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        title: Text(
          'Receipt Scanner',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (receiptState.receiptData != null)
            IconButton(
              onPressed: () => receiptNotifier.resetData(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: receiptState.isProcessing
          ? _buildLoadingWidget()
          : receiptState.receiptData == null
              ? _buildEmptyState(context, receiptNotifier)
              : _buildReceiptDetails(context, receiptState, receiptNotifier),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _purple,
            strokeWidth: 3,
          ),
          SizedBox(height: 24.h),
          Text(
            'Processing receipt...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReceiptNotifier notifier) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40.h),
          // Illustration
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: _purpleSoft,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.receipt_long,
              size: 100.sp,
              color: _purple,
            ),
          ),
          SizedBox(height: 32.h),

          // Title
          Text(
            'Scan Your Receipt',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'Take a photo or select an image from your gallery to extract receipt details automatically',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildPickerOption(
                  label: 'Gallery',
                  icon: Icons.photo_library_outlined,
                  color: _purple,
                  onTap: () => notifier.processImageExtractText(
                    imageSource: ImageSource.gallery,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildPickerOption(
                  label: 'Camera',
                  icon: Icons.camera_alt_outlined,
                  color: _purpleLight,
                  onTap: () => notifier.processImageExtractText(
                    imageSource: ImageSource.camera,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // Features
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildPickerOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.speed, 'text': 'Fast & Accurate scanning'},
      {'icon': Icons.receipt, 'text': 'Extract totals & items'},
      {'icon': Icons.save_alt, 'text': 'Save for expense tracking'},
    ];

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ...features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: _purple,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      feature['text'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReceiptDetails(
    BuildContext context,
    ReceiptState receiptState,
    ReceiptNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scanned Image Preview
          if (receiptState.scannedImage != null)
            Container(
              height: 200.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  receiptState.scannedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Merchant Info Card
          _buildInfoCard(
            title: 'Merchant Details',
            icon: Icons.store,
            children: [
              _buildInfoRow('Name', receiptState.receiptData!.merchantName),
              if (receiptState.receiptData!.date != null)
                _buildInfoRow('Date', receiptState.receiptData!.date!),
            ],
          ),
          SizedBox(height: 16.h),

          // Items Card
          if (receiptState.receiptData!.items.isNotEmpty)
            _buildInfoCard(
              title: 'Items (${receiptState.receiptData!.items.length})',
              icon: Icons.shopping_cart,
              children: [
                ...receiptState.receiptData!.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          if (receiptState.receiptData!.items.isNotEmpty)
            SizedBox(height: 16.h),

          // Financial Summary Card
          _buildSummaryCard(receiptState.receiptData!),
          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'View Raw Text',
                  icon: Icons.text_snippet_outlined,
                  onTap: () =>
                      _showRawTextDialog(context, receiptState.extractedText),
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  label: 'Add to Expense',
                  icon: Icons.add_circle_outline,
                  onTap: () {
                    // Navigate back with receipt data
                    Navigator.pop(context, receiptState.receiptData);
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: _purpleSoft,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: _purple,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ReceiptData receiptData) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_purple, _purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (receiptData.subtotal != null)
            _buildSummaryRow(
              'Subtotal',
              '\$${receiptData.subtotal!.toStringAsFixed(2)}',
              isHighlight: false,
            ),
          if (receiptData.tax != null)
            _buildSummaryRow(
              'Tax',
              '\$${receiptData.tax!.toStringAsFixed(2)}',
              isHighlight: false,
            ),
          if (receiptData.subtotal != null || receiptData.tax != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(color: Colors.white.withOpacity(0.3)),
            ),
          _buildSummaryRow(
            'Total',
            receiptData.total != null
                ? '\$${receiptData.total!.toStringAsFixed(2)}'
                : 'Not found',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {required bool isHighlight}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isHighlight ? 0 : 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 18.sp : 15.sp,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 24.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? _green : Colors.white,
        foregroundColor: isPrimary ? Colors.white : _purple,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        elevation: isPrimary ? 3 : 0,
        shadowColor: isPrimary ? _green.withOpacity(0.4) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: _purple, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showRawTextDialog(BuildContext context, String extractedText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Extracted Text',
              style: TextStyle(fontSize: 18.sp),
            ),
            IconButton(
              onPressed: () => _copyToClipBoard(context, extractedText),
              icon: const Icon(Icons.copy),
              tooltip: 'Copy',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            extractedText,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
