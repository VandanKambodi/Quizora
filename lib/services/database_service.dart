import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Real-time stream for the current teacher's dashboard
  Stream<QuerySnapshot> getTeacherQuizzes() {
    final user = _auth.currentUser;
    return _db
        .collection('quizzes')
        .where(
          Filter.or(
            Filter('createdBy', isEqualTo: user?.uid),
            Filter('collaborators', arrayContains: user?.email),
          ),
        )
        .snapshots();
  }

  Future<void> createFullQuiz({
    required String title,
    required int timer,
    required String description,
    required String category,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      DocumentReference quizRef = await _db.collection('quizzes').add({
        'title': title,
        'timer': timer,
        'description': description,
        'category': category,
        'createdBy': _auth.currentUser?.uid,
        'assignedStudents': [],
        'collaborators': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;
        for (int i = 1; i < rows.length; i++) {
          // Skip header row
          var row = rows[i];
          if (row[0] == null || row[0]?.value == null) continue;
          await quizRef.collection('questions').add({
            'question': row[0]?.value.toString(),
            'options': [
              row[1]?.value.toString(),
              row[2]?.value.toString(),
              row[3]?.value.toString(),
              row[4]?.value.toString(),
            ],
            'answer': row[5]?.value.toString(),
          });
        }
      }
    }
  }

  Future<void> assignStudents(String quizId, List<String> emails) async {
    for (String email in emails) {
      String cleanEmail = email.trim().toLowerCase();

      QuerySnapshot userCheck =
          await _db
              .collection('users')
              .where('email', isEqualTo: cleanEmail)
              .get();

      if (userCheck.docs.isNotEmpty) {
        String role = userCheck.docs.first['role'];
        if (role == 'Teacher') {
          throw Exception(
            "Email $cleanEmail belongs to a Teacher and cannot be assigned.",
          );
        }
      }
    }

    await _db.collection('quizzes').doc(quizId).update({
      'assignedStudents': FieldValue.arrayUnion(
        emails.map((e) => e.trim()).toList(),
      ),
    });
  }

  Future<void> deleteQuiz(String quizId) async {
    await _db.collection('quizzes').doc(quizId).delete();
  }

  Future<void> updateQuizDetails(
    String quizId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('quizzes').doc(quizId).update(data);
  }

  //Remove a specific student from the quiz
  Future<void> removeStudentFromQuiz(String quizId, String email) async {
    await _db.collection('quizzes').doc(quizId).update({
      'assignedStudents': FieldValue.arrayRemove([email]),
    });
  }

  //Update email but ensure it stays unique
  Future<void> updateStudentEmail(
    String quizId,
    String oldEmail,
    String newEmail,
  ) async {
    DocumentReference quizRef = _db.collection('quizzes').doc(quizId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(quizRef);
      List<dynamic> students = List.from(snapshot.get('assignedStudents'));

      if (students.contains(newEmail)) {
        throw Exception("This student is already assigned to this quiz!");
      }

      int index = students.indexOf(oldEmail);
      if (index != -1) {
        students[index] = newEmail;
        transaction.update(quizRef, {'assignedStudents': students});
      }
    });
  }

  Future<void> updateCollaboratorEmail(
    String quizId,
    String oldEmail,
    String newEmail,
  ) async {
    DocumentReference quizRef = _db.collection('quizzes').doc(quizId);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(quizRef);
      List<dynamic> collaborators = List.from(
        snapshot.get('collaborators') ?? [],
      );
      int index = collaborators.indexOf(oldEmail);
      if (index != -1) {
        collaborators[index] = newEmail.trim().toLowerCase();
        transaction.update(quizRef, {'collaborators': collaborators});
      }
    });
  }

  Future<void> addCollaborator(String quizId, String email) async {
    await _db.collection('quizzes').doc(quizId).update({
      'collaborators': FieldValue.arrayUnion([email.trim().toLowerCase()]),
    });
  }

  // DELETE: Remove a teacher from the collaborators list
  Future<void> removeCollaborator(String quizId, String email) async {
    try {
      await _db.collection('quizzes').doc(quizId).update({
        'collaborators': FieldValue.arrayRemove([email.trim().toLowerCase()]),
      });
    } catch (e) {
      throw Exception("Failed to remove collaborator: $e");
    }
  }

  // Check if student already attempted this quiz
  Future<bool> hasAttempted(String quizId) async {
    try {
      String? email = _auth.currentUser?.email;
      // Simple query to avoid complex index requirements where possible
      var snap =
          await _db
              .collection('results')
              .where('quizId', isEqualTo: quizId)
              .where('studentEmail', isEqualTo: email)
              .get();

      return snap.docs.isNotEmpty;
    } catch (e) {
      print("Index or Permission Error: $e");
      return false;
    }
  }
}
