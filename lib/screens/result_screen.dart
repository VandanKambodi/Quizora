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
    double percentage = total > 0 ? (score / total) * 100 : 0;
    bool isPassed = percentage >= 50;

    return Scaffold(
      backgroundColor: qBg,
      body: Column(
        children: [
          _buildScoreHeader(context, isPassed, percentage),

          Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Row(
              children: [
                Text(
                  "Review Answers",
                  style: qTitleStyle.copyWith(
                    fontSize: 18,
                    color: qTextPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: qPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$total Questions",
                    style: const TextStyle(
                      color: qPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: reviewData.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = reviewData[index];
                return _buildAnimatedReviewCard(item, index);
              },
            ),
          ),

          // --- PERSISTENT BOTTOM BUTTON ---
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(
    BuildContext context,
    bool isPassed,
    double percentage,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isPassed ? "Congratulations!" : "Don't Give Up!",
            style: qTitleStyle.copyWith(
              fontSize: 24,
              color: isPassed ? qPrimary : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isPassed
                ? "You've successfully cleared the quiz."
                : "Keep practicing to improve your score.",
            textAlign: TextAlign.center,
            style: qSubTitleStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 25),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: qBg,
                  color: isPassed ? qPrimary : Colors.orangeAccent,
                ),
              ),
              Column(
                children: [
                  Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: qTitleStyle.copyWith(fontSize: 28),
                  ),
                  Text(
                    "SCORE",
                    style: qSubTitleStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Summary Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("Correct", "$score", Colors.green),
              Container(height: 30, width: 1, color: qBg),
              _buildStatItem("Wrong", "${total - score}", Colors.redAccent),
              Container(height: 30, width: 1, color: qBg),
              _buildStatItem("Total", "$total", qPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: qGrey)),
      ],
    );
  }

  Widget _buildAnimatedReviewCard(dynamic item, int index) {
    bool correct = item['isCorrect'] ?? false;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: qWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                correct
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  correct
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              correct ? Icons.check_rounded : Icons.close_rounded,
              color: correct ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          title: Text(
            item['question'] ?? "Question",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: qTextPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnswerBox(
                  "Your Answer",
                  item['selected'],
                  correct ? Colors.green : Colors.red,
                ),
                if (!correct) ...[
                  const SizedBox(height: 8),
                  _buildAnswerBox(
                    "Correct Answer",
                    item['correct'],
                    Colors.green,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
      decoration: BoxDecoration(
        color: qWhite,
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: qPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () => Navigator.pop(context),
        child: Text("BACK TO DASHBOARD", style: qButtonStyle),
      ),
    );
  }
}
