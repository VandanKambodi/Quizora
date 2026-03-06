import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileService {
  final ImagePicker _picker = ImagePicker();

  Future<void> updateProfileImage() async {
    try {
      // Request gallery permission
      PermissionStatus status = await Permission.photos.request();

      if (!status.isGranted) {
        print("Permission denied");
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        imageQuality: 50,
      );

      if (image == null) return;

      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profileItem': base64Image,
      }, SetOptions(merge: true));

      print("Image updated successfully!");
    } catch (e) {
      print("Error picking image: $e");
    }
  }
}
