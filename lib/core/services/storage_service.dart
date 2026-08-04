import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Upload file to Firebase Storage under specified folder
  static Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  }) async {
    try {
      String extension = fileName.contains('.') ? fileName.split('.').last : 'file';
      String uniqueName = '${_uuid.v4()}_$fileName';
      Reference ref = _storage.ref().child('$folder/$uniqueName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      rethrow;
    }
  }
}
