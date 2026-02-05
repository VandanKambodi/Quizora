import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import 'result_screen.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('results')
                .where('studentEmail', isEqualTo: email)
                .orderBy('submittedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(
              child: Text(
                "Error loading history. Check your Firebase Indexes.",
              ),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final results = snapshot.data!.docs;
          if (results.isEmpty)
            return const Center(child: Text("No quizzes completed yet."));

          return ListView.builder(
            itemCount: results.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var data = results[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: qPrimary),
                  title: Text(data['quizTitle'] ?? "Quiz Result"),
                  subtitle: Text(
                    "Score: ${data['score'] ?? 0} / ${data['total'] ?? 0}",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    var data = results[index].data() as Map<String, dynamic>;

                    // FIX: Safe check to handle documents where 'review' is missing
                    List<dynamic> reviewList =
                        data['review'] != null
                            ? List<dynamic>.from(data['review'])
                            : [];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ResultScreen(
                              score: data['score'] ?? 0,
                              total: data['total'] ?? 0,
                              reviewData: reviewList, // Passes the safe list
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
