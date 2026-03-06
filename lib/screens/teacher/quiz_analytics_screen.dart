import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants.dart';
import '../result_screen.dart';
import 'quiz_leaderboard.dart';

class QuizAnalyticsScreen extends StatelessWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const QuizAnalyticsScreen({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  Widget build(BuildContext context) {
    List assignedEmails = quizData['assignedStudents'] ?? [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: qBg,
        appBar: AppBar(
          backgroundColor: qPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: qWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            quizData['title'],
            style: const TextStyle(
              color: qWhite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.leaderboard_rounded,
                color: Colors.amberAccent,
                size: 28,
              ),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => QuizLeaderboard(
                            quizId: quizId,
                            quizTitle: quizData['title'],
                          ),
                    ),
                  ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('results')
                  .where('quizId', isEqualTo: quizId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                child: CircularProgressIndicator(color: qPrimary),
              );

            var finishedDocs = snapshot.data!.docs;
            var finishedEmails =
                finishedDocs.map((doc) => doc['studentEmail']).toList();
            int total = assignedEmails.length;
            int done = finishedDocs.length;
            int pending = total - done;
            double completionRate = total > 0 ? (done / total) : 0;

            return Column(
              children: [
                _buildHeaderStats(total, done, completionRate),
                const TabBar(
                  labelColor: qPrimary,
                  unselectedLabelColor: qGrey,
                  indicatorColor: qPrimary,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: "Finished"),
                    Tab(text: "Pending"),
                    Tab(text: "Stats"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDoneList(finishedDocs),
                      _buildPendingList(assignedEmails, finishedEmails),
                      _buildStatisticsTab(
                        done,
                        pending,
                        finishedDocs,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(
    int done,
    int pending,
    List<QueryDocumentSnapshot> docs,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Completion Ratio",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: done.toDouble(),
                    title: 'Done ($done)',
                    color: Colors.greenAccent,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  PieChartSectionData(
                    value: pending.toDouble(),
                    title: 'Pending ($pending)',
                    color: Colors.orangeAccent,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Score Distribution",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 30),
          _buildScoreBarChart(docs),
        ],
      ),
    );
  }

  // --- STEP D2: PREPARE DATASET FROM FIRESTORE ---
  Widget _buildScoreBarChart(List<QueryDocumentSnapshot> docs) {
    int low = 0;
    int mid = 0;
    int high = 0;

    for (var doc in docs) {
      double p = (doc['score'] / doc['total']) * 100;
      if (p < 50)
        low++;
      else if (p < 80)
        mid++;
      else
        high++;
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (low > mid
                      ? (low > high ? low : high)
                      : (mid > high ? mid : high))
                  .toDouble() +
              1,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: low.toDouble(),
                  color: Colors.redAccent,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: mid.toDouble(),
                  color: Colors.orangeAccent,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: high.toDouble(),
                  color: Colors.greenAccent,
                  width: 20,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  const titles = ['0-50%', '50-80%', '80-100%'];
                  return Text(
                    titles[val.toInt()],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(int total, int done, double completionRate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
      decoration: const BoxDecoration(
        color: qPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat("Assigned", "$total", Icons.people_outline),
              _buildHeaderStat("Done", "$done", Icons.check_circle_outline),
              _buildHeaderStat(
                "Pending",
                "${total - done}",
                Icons.hourglass_empty,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              backgroundColor: qWhite.withOpacity(0.2),
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: qWhite.withOpacity(0.8), size: 20),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: qWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: qWhite.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDoneList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty)
      return _buildEmptyState("No students finished yet", Icons.history_edu);
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        double scorePercent = (data['score'] / data['total']) * 100;
        return _buildListContainer(
          child: ListTile(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ResultScreen(
                          score: data['score'] ?? 0,
                          total: data['total'] ?? 0,
                          reviewData: data['review'] ?? [],
                        ),
                  ),
                ),
            leading: CircleAvatar(
              backgroundColor: qPrimary.withOpacity(0.1),
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: qPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              data['studentEmail'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              "Score: ${data['score']} / ${data['total']}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: _buildScoreBadge(scorePercent),
          ),
        );
      },
    );
  }

  Widget _buildPendingList(List assigned, List finished) {
    var pending = assigned.where((email) => !finished.contains(email)).toList();
    if (pending.isEmpty)
      return _buildEmptyState(
        "Everyone has finished!",
        Icons.celebration_rounded,
      );
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pending.length,
      itemBuilder:
          (context, index) => _buildListContainer(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.person_outline, color: Colors.grey),
              ),
              title: Text(
                pending[index],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: const Text(
                "Attempt Pending",
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
              trailing: const Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: qGrey,
              ),
            ),
          ),
    );
  }

  Widget _buildListContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildScoreBadge(double scorePercent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            scorePercent >= 50
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "${scorePercent.toStringAsFixed(0)}%",
        style: TextStyle(
          color: scorePercent >= 50 ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: qGrey.withOpacity(0.3)),
          const SizedBox(height: 15),
          Text(
            msg,
            style: const TextStyle(color: qGrey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
