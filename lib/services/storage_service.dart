import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadEvidence(File file, String complaintId) async {
    final ref = _storage.ref('evidence').child('$complaintId.jpg');
    final uploadTask = await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }
}
