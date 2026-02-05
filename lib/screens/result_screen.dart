import 'package:flutter/material.dart';
import '../constants.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final List<dynamic> reviewData;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.reviewData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Review"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: BoxDecoration(color: qPrimary.withOpacity(0.1)),
            child: Column(
              children: [
                const Text("Score Achieved", style: TextStyle(fontSize: 16)),
                Text(
                  "$score / $total",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: qPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reviewData.length,
              itemBuilder: (context, index) {
                final item = reviewData[index];
                return ListTile(
                  leading: Icon(
                    item['isCorrect'] ? Icons.check_circle : Icons.cancel,
                    color: item['isCorrect'] ? Colors.green : Colors.red,
                  ),
                  title: Text(item['question'] ?? "Question"),
                  subtitle: Text(
                    "Selected: ${item['selected']}\nCorrect: ${item['correct']}",
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: qPrimary),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "BACK TO DASHBOARD",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
