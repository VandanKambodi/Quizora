import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../constants.dart';
import 'quiz_analytics_screen.dart';

class AllResultsPage extends StatefulWidget {
  const AllResultsPage({super.key});

  @override
  State<AllResultsPage> createState() => _AllResultsPageState();
}

class _AllResultsPageState extends State<AllResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: qPrimary,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 85),
              title: Text(
                "Quiz Analytics",
                style: qTitleStyle.copyWith(
                  color: qWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: qWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: qBlack.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search quiz title...",
                      hintStyle: const TextStyle(color: qGrey, fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: qPrimary,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: qGrey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
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

              final allQuizzes = snapshot.data?.docs ?? [];
              final filteredQuizzes =
                  allQuizzes.where((doc) {
                    String title =
                        (doc.data() as Map<String, dynamic>)['title'] ?? "";
                    return title.toLowerCase().contains(_searchQuery);
                  }).toList();

              if (filteredQuizzes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: qGrey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? "No quizzes found"
                              : "No results for '$_searchQuery'",
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
                        filteredQuizzes[index].data() as Map<String, dynamic>;
                    String quizId = filteredQuizzes[index].id;
                    return _buildAnalyticalQuizCard(
                      context,
                      quizId,
                      quizData,
                      index,
                    );
                  }, childCount: filteredQuizzes.length),
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
                    if (!summarySnap.hasData)
                      return const LinearProgressIndicator();
                    var results = summarySnap.data!.docs;
                    int assigned =
                        (quizData['assignedStudents'] as List).length;
                    int completed = results.length;
                    int top =
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
                          "$completed/$assigned",
                        ),
                        _miniStat(
                          Icons.emoji_events_rounded,
                          "Top Score",
                          "$top",
                        ),
                        _miniStat(
                          Icons.trending_up_rounded,
                          "Status",
                          completed == assigned ? "Finished" : "Active",
                          isStatus: true,
                          isComplete: completed == assigned,
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
        Text(label, style: const TextStyle(fontSize: 10, color: qGrey)),
      ],
    );
  }
}
