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
    _timeLeft = widget.quizData['timer'] * 60;
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
        _submitQuiz();
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: qBg,
        body: Center(child: CircularProgressIndicator(color: qPrimary)),
      );
    }

    var currentQ = _questions[_currentIndex];
    String? currentSelection = _selectedAnswers[_currentIndex];
    bool isLast = _currentIndex == _questions.length - 1;
    final options = currentQ['options'] as List;

    return Scaffold(
      backgroundColor: qBg,
      body: Stack(
        children: [
          // Background color reduced to top 35% for better contrast
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            color: qPrimary,
          ),
          SafeArea(
            child: Column(
              children: [
                _buildModernHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey<int>(_currentIndex),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    child: Column(
                      children: [
                        _buildFloatingQuestionCard(currentQ['question']),
                        const SizedBox(height: 30),
                        ...options.asMap().entries.map((entry) {
                          String label = String.fromCharCode(65 + entry.key);
                          return _buildChoiceTile(
                            entry.value,
                            label,
                            currentSelection == entry.value,
                            entry.key,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildGlassBottomNav(isLast),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: qWhite),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.quizData['title'] ?? "Quiz",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: qWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: qWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${(_timeLeft ~/ 60)}:${(_timeLeft % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(
                color: qWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingQuestionCard(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "QUESTION ${_currentIndex + 1}",
                style: qSubTitleStyle.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "${_currentIndex + 1}/${_questions.length}",
                style: const TextStyle(
                  color: qPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(thickness: 0.5),
          const SizedBox(height: 15),
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: qTextPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceTile(
    String option,
    String label,
    bool selected,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, anim, child) {
        double safeOpacity = anim.clamp(0.0, 1.0);
        return Opacity(opacity: safeOpacity, child: child);
      },
      child: GestureDetector(
        onTap: () => setState(() => _selectedAnswers[_currentIndex] = option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: selected ? qPrimary : qWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? qPrimary : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: selected ? qWhite.withOpacity(0.2) : qBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? qWhite : qPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color:
                        selected ? qWhite : qTextPrimary, // High contrast text
                  ),
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: qWhite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBottomNav(bool isLast) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: qWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentIndex > 0)
            InkWell(
              onTap: () => setState(() => _currentIndex--),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: qBg, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: qPrimary, size: 22),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: qPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed:
                  () =>
                      isLast ? _submitQuiz() : setState(() => _currentIndex++),
              child: Text(
                isLast ? "FINISH" : "NEXT QUESTION",
                style: const TextStyle(
                  color: qWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
