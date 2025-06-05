import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; 

Future<String?> uploadImageAndGetUrl() async {
  try {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');

    if (kIsWeb) {
      // 웹: FilePicker 사용
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final Uint8List fileBytes = result.files.single.bytes!;
        await ref.putData(fileBytes, SettableMetadata(contentType: 'image/png'));
        return await ref.getDownloadURL();
      }
    } else {
      // 모바일(Android/iOS): ImagePicker 사용
      final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        await ref.putFile(file);
        return await ref.getDownloadURL();
      }
    }

    return null; // 선택이 취소되거나 실패했을 경우
  } catch (e) {
    print('이미지 업로드 실패: $e');
    return null;
  }
}
