import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:try1/widgets_screen/ai/model/recepit.dart';

import '../../generated/l10n.dart';

class RecpitPage extends StatefulWidget {
  const RecpitPage({super.key});

  @override
  State<RecpitPage> createState() => _RecpitPageState();
}

class _RecpitPageState extends State<RecpitPage> {
  /// Variable that will store the text extracted from the image
  String _extractedText = '';

  /// Pick a image from a source
  /// Requires a [source]
  Future<File?> _pickerImage({required ImageSource source}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Allow crop a image file
  /// Requires a [imageFile]
  Future<CroppedFile?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedfile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
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
        ),
      ],
    );

    if (croppedfile != null) {
      return croppedfile;
    }

    return null;
  }

  /// Create a instance from [TextRecognizer] and try extract text from a image
  /// Requires a [imgPath]
  Future<String> _recognizeTextFromImage({required String imgPath}) async {
    /// Create an instance of TextRecognizer
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    /// Process image
    final image = InputImage.fromFile(File(imgPath));
    final recognized = await textRecognizer.processImage(image);

    return recognized.text;
  }

  /// Allows you to select an image from a source
  /// Crop the selected image
  /// Processes the image and extracts found text information
  /// Requires a [imageSource]
  Future<void> _processImageExtractText({
    required ImageSource imageSource,
  }) async {
    final imageFile = await _pickerImage(source: imageSource);

    if (imageFile == null) return;

    final croppedImage = await _cropImage(
      imageFile: imageFile,
    );

    if (croppedImage == null) return;

    final recognizedText = await _recognizeTextFromImage(
      imgPath: croppedImage.path,
    );

    setState(() => _extractedText = recognizedText);
  }

  /// Copy the content from [_extractedText] to clip board and show a snackbar alert
  void _copyToClipBoard() {
    Clipboard.setData(ClipboardData(text: _extractedText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).copiedToClipboard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).flutterOcr)),
      body: Column(
        children: [
          Text(
            S.of(context).selectAOption,
            style: TextStyle(fontSize: 22.0),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PickerOptionWidget(
                  label: S.of(context).fromGallery,
                  color: Colors.blueAccent,
                  icon: Icons.image_outlined,
                  onTap: () => _processImageExtractText(
                    imageSource: ImageSource.gallery,
                  ),
                ),
                const SizedBox(width: 10.0),
                PickerOptionWidget(
                  label: S.of(context).fromCamera,
                  color: Colors.redAccent,
                  icon: Icons.camera_alt_outlined,
                  onTap: () => _processImageExtractText(
                    imageSource: ImageSource.camera,
                  ),
                ),
              ],
            ),
          ),
          if (_extractedText.isNotEmpty) ...{
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).previouslyRead,
                    style: TextStyle(fontSize: 22.0),
                  ),
                  IconButton(
                    onPressed: _copyToClipBoard,
                    icon: const Icon(Icons.copy),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 20.0,
                    ),
                    child: Text(_extractedText),
                  ),
                ),
              ),
            )
          },
        ],
      ),
    );
  }
}
