import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../constants.dart';
import 'quiz_analytics_screen.dart';

class AllResultsPage extends StatelessWidget {
  const AllResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      body: CustomScrollView(
        slivers: [
          // SLIVER HEADER
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: qPrimary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Quiz Analytics",
                style: qTitleStyle.copyWith(color: qWhite, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [qPrimary, qPrimaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: DatabaseService().getTeacherQuizzes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: qPrimary),
                  ),
                );
              }

              final quizzes = snapshot.data?.docs ?? [];

              if (quizzes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 80,
                          color: qGrey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No quizzes found to analyze",
                          style: qSubTitleStyle,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var quizData =
                        quizzes[index].data() as Map<String, dynamic>;
                    String quizId = quizzes[index].id;
                    return _buildAnalyticalQuizCard(
                      context,
                      quizId,
                      quizData,
                      index,
                    );
                  }, childCount: quizzes.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticalQuizCard(
    BuildContext context,
    String quizId,
    Map<String, dynamic> quizData,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder:
          (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: qWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: qBlack.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => QuizAnalyticsScreen(
                        quizId: quizId,
                        quizData: quizData,
                      ),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: qPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assessment_rounded,
                        color: qPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quizData['title'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: qTextPrimary,
                            ),
                          ),
                          Text(
                            quizData['category'] ?? "General",
                            style: qSubTitleStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: qGrey),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(height: 1),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getQuizSummary(quizId),
                  builder: (context, summarySnap) {
                    if (!summarySnap.hasData) {
                      return const Center(child: LinearProgressIndicator());
                    }
                    var results = summarySnap.data!.docs;
                    int assignedCount =
                        (quizData['assignedStudents'] as List).length;
                    int completedCount = results.length;

                    int highScore =
                        results.isEmpty
                            ? 0
                            : results
                                .map((d) => d['score'] as int)
                                .reduce((a, b) => a > b ? a : b);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniStat(
                          Icons.people_alt_rounded,
                          "Participation",
                          "$completedCount/$assignedCount",
                        ),
                        _miniStat(
                          Icons.emoji_events_rounded,
                          "Top Score",
                          "$highScore",
                        ),
                        _miniStat(
                          Icons.trending_up_rounded,
                          "Status",
                          completedCount == assignedCount
                              ? "Finished"
                              : "Active",
                          isStatus: true,
                          isComplete: completedCount == assignedCount,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
    bool isComplete = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              isStatus
                  ? (isComplete ? Colors.green : Colors.orange)
                  : qPrimary.withOpacity(0.7),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color:
                isStatus
                    ? (isComplete ? Colors.green : Colors.orange)
                    : qTextPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: qGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
