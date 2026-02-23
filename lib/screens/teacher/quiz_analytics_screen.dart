import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      length: 2,
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
            double completionRate = total > 0 ? (done / total) : 0;

            return Column(
              children: [
                Container(
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
                          _buildHeaderStat(
                            "Assigned",
                            "$total",
                            Icons.people_outline,
                          ),
                          _buildHeaderStat(
                            "Done",
                            "$done",
                            Icons.check_circle_outline,
                          ),
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
                ),

                const TabBar(
                  labelColor: qPrimary,
                  unselectedLabelColor: qGrey,
                  indicatorWeight: 3,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
                  indicatorColor: qPrimary,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: [Tab(text: "Finished"), Tab(text: "Pending")],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDoneList(finishedDocs),
                      _buildPendingList(assignedEmails, finishedEmails),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        double scorePercent = (data['score'] / data['total']) * 100;

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
            trailing: Container(
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
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: pending.length,
      itemBuilder:
          (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: qWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: qBg, width: 2),
            ),
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
