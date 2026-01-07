import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _titleController = TextEditingController();
  final _timerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizora Teacher", style: TextStyle(color: qWhite)),
        backgroundColor: qBlue,
        actions: [
          // Helpful to have a logout button to test both roles
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                () => FirebaseAuth.instance.signOut().then(
                  (_) => Navigator.pushReplacementNamed(context, '/login'),
                ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Quiz Title"),
            ),
            TextField(
              controller: _timerController,
              decoration: const InputDecoration(labelText: "Timer (minutes)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: qBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await DatabaseService().uploadQuizFromExcel(
                  _titleController.text,
                  int.parse(_timerController.text),
                );
                _titleController.clear();
                _timerController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Quiz Uploaded Successfully!")),
                );
              },
              child: const Text(
                "UPLOAD EXCEL SHEET",
                style: TextStyle(color: qWhite),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Quizzes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // NEW SECTION: This is what was missing!
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Fetch quizzes only created by THIS teacher
                stream:
                    FirebaseFirestore.instance
                        .collection('quizzes')
                        .where(
                          'createdBy',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Text("Something went wrong");
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  final quizzes = snapshot.data!.docs;

                  if (quizzes.isEmpty) {
                    return const Center(
                      child: Text("No quizzes uploaded yet."),
                    );
                  }

                  return ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      var data = quizzes[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.description, color: qBlue),
                          title: Text(data['title'] ?? 'No Title'),
                          subtitle: Text("Time: ${data['timer']} mins"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
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
    );
  }
}
