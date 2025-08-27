import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseStorageService._privateConstructor();
  static final FirebaseStorageService instance =
      FirebaseStorageService._privateConstructor();

  final Uuid _uuid = const Uuid();

  Future<String> uploadFile({
    required File file,
    required String folder,
    String? oldFilePath,
  }) async {
    try {
      final fileName = "${_uuid.v4()}${path.extension(file.path)}";
      final ref = _storage.ref().child("$folder/$fileName");

      final mimeType = lookupMimeType(file.path);

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: mimeType),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  Future<String> uploadBytes({
    required Uint8List data,
    required String folder,
    String? fileExtension,
    String? oldFilePath,
  }) async {
    try {
      final ext = fileExtension ?? ".jpg";
      final fileName = "${_uuid.v4()}$ext";
      final ref = _storage.ref().child("$folder/$fileName");

      final uploadTask = await ref.putData(
        data,
        SettableMetadata(contentType: lookupMimeType(fileName)),
      );

      if (oldFilePath != null && oldFilePath.isNotEmpty) {}

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Upload bytes failed: $e");
    }
  }

  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Get URL failed: $e");
    }
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == "object-not-found") {
        return;
      }
      throw Exception("Delete failed: $e");
    }
  }
}
