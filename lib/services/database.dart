import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // This function handles the "Motive" of uploading a quiz
  Future<void> uploadQuizFromExcel(String quizTitle, int timer) async {
    // 1. Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // 2. Create the Quiz Document
      DocumentReference quizRef = await _db.collection('quizzes').add({
        'title': quizTitle,
        'timer': timer,
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': DateTime.now(),
      });

      // 3. Read Rows (Assuming: Row 1 is headers)
      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;
        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row[0] == null) continue; // Skip empty rows

          // Add questions to a sub-collection
          await quizRef.collection('questions').add({
            'questionText': row[0]?.value.toString(),
            'options': [
              row[1]?.value.toString(),
              row[2]?.value.toString(),
              row[3]?.value.toString(),
              row[4]?.value.toString(),
            ],
            'correctAnswer': row[5]?.value.toString(),
          });
        }
      }
    }
  }
}