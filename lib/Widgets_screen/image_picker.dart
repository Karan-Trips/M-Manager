import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../generated/l10n.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery
  static Future<File?> pickImageFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Capture an image using the camera
  static Future<File?> pickImageFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  /// Common function to pick an image
  static Future<File?> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        debugPrint("User canceled image selection.");
        return null;
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  /// Show a dialog to let the user choose between Camera or Gallery
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(S.of(context).camera),
              onTap: () async {
                Navigator.pop(context, await pickImageFromCamera());
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context).gallery),
              onTap: () async {
                Navigator.pop(context, await pickImageFromGallery());
              },
            ),
          ],
        );
      },
    );
  }
}
