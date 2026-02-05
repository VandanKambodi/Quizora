import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;
  const ExamScreen({super.key, required this.quizId, required this.quizData});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  late int _timeLeft;
  Timer? _timer;
  List<DocumentSnapshot> _questions = [];
  Map<int, String> _selectedAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.quizData['timer'] * 60; // Minutes to Seconds
    _loadQuestions();
    _startTimer();
  }

  Future<void> _loadQuestions() async {
    var snap =
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .collection('questions')
            .get();
    setState(() {
      _questions = snap.docs;
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _submitQuiz(); // AUTO-SUBMIT on timeout
      }
    });
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    int score = 0;
    List<Map<String, dynamic>> reviewData = [];

    for (int i = 0; i < _questions.length; i++) {
      String selected = _selectedAnswers[i] ?? "No Answer";
      String correct = _questions[i]['answer'];
      bool isCorrect = selected == correct;
      if (isCorrect) score++;

      reviewData.add({
        'question': _questions[i]['question'],
        'selected': selected,
        'correct': correct,
        'isCorrect': isCorrect,
      });
    }

    await FirebaseFirestore.instance.collection('results').add({
      'quizId': widget.quizId,
      'quizTitle': widget.quizData['title'],
      'studentEmail': FirebaseAuth.instance.currentUser?.email,
      'score': score,
      'total': _questions.length,
      'review': reviewData,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResultScreen(
                score: score,
                total: _questions.length,
                reviewData: reviewData,
              ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    var currentQ = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Time: ${(_timeLeft ~/ 60)}:${(_timeLeft % 60).toString().padLeft(2, '0')}",
        ),
        backgroundColor: _timeLeft < 30 ? Colors.red : qPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              color: qPrimary,
            ),
            const SizedBox(height: 25),
            Text(
              currentQ['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: ListView(
                children:
                    (currentQ['options'] as List).map((option) {
                      return Card(
                        child: RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          activeColor: qPrimary,
                          groupValue: _selectedAnswers[_currentIndex],
                          onChanged:
                              (val) => setState(
                                () => _selectedAnswers[_currentIndex] = val!,
                              ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentIndex--),
                    child: const Text("PREV"),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: qPrimary),
                  onPressed:
                      () =>
                          _currentIndex < _questions.length - 1
                              ? setState(() => _currentIndex++)
                              : _submitQuiz(),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? "NEXT" : "SUBMIT",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
