import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String?> pickAvatarImagePath({ImageSource source = ImageSource.gallery}) async {
  final pickedFile = await ImagePicker().pickImage(source: source);
  if (pickedFile == null) return null;

  if (kIsWeb) {
    final bytes = await pickedFile.readAsBytes();
    final mime = pickedFile.mimeType ?? 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  final directory = await getApplicationDocumentsDirectory();
  final fileName = path.basename(pickedFile.path);
  final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
  return savedImage.path;
}
