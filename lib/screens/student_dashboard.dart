import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import 'exam_screen.dart';
import '../services/database_service.dart';
import 'result_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizora"),
        backgroundColor: qPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: qWhite),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F7F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
                child: Text(
                  "Welcome, ${user?.email?.split('@')[0] ?? 'Student'} 👋",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Quizzes assigned to you",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('quizzes')
                          .where('assignedStudents', arrayContains: user?.email)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Center(child: Text("Error loading quizzes"));
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: qPrimary),
                      );
                    }
                    final quizzes = snapshot.data!.docs;
                    if (quizzes.isEmpty)
                      return const Center(
                        child: Text("No quizzes assigned yet."),
                      );

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final data =
                            quizzes[index].data() as Map<String, dynamic>;
                        final quizId = quizzes[index].id;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: qPrimary.withOpacity(0.12),
                                child: const Icon(
                                  Icons.assignment,
                                  color: qPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "⏱ ${data['timer']} mins • ${data['category'] ?? 'General'}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: qPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () async {
                                  var resultSnap =
                                      await FirebaseFirestore.instance
                                          .collection('results')
                                          .where('quizId', isEqualTo: quizId)
                                          .where(
                                            'studentEmail',
                                            isEqualTo: user?.email,
                                          )
                                          .get();

                                  if (resultSnap.docs.isNotEmpty) {
                                    // REDIRECT TO RESULT if already done
                                    var doc = resultSnap.docs.first.data();
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ResultScreen(
                                                score: doc['score'],
                                                total: doc['total'],
                                                reviewData: doc['review'],
                                              ),
                                        ),
                                      );
                                    }
                                  } else {
                                    // START QUIZ if not done
                                    if (context.mounted)
                                      _startQuiz(context, quizId, data);
                                  }
                                },
                                child: const Text(
                                  "START",
                                  style: TextStyle(color: qWhite),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(
    BuildContext context,
    String quizId,
    Map<String, dynamic> quizData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamScreen(quizId: quizId, quizData: quizData),
      ),
    );
  }
}
