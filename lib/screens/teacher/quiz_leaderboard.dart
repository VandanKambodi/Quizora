import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';

class QuizLeaderboard extends StatelessWidget {
  final String quizId;
  final String quizTitle;

  const QuizLeaderboard({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      appBar: AppBar(
        backgroundColor: qPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: qWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Leaderboard",
          style: const TextStyle(color: qWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('results')
                .where('quizId', isEqualTo: quizId)
                .orderBy('score', descending: true)
                .orderBy('timeUsedSeconds', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildErrorState();
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: qPrimary),
            );

          final results = snapshot.data!.docs;
          if (results.isEmpty) return _buildEmptyState();

          return Column(
            children: [
              // PODIUM SECTION (Top 3)
              _buildPodium(results),

              // REMAINING PLAYERS LIST
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: qWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                    itemCount: results.length > 3 ? results.length - 3 : 0,
                    separatorBuilder:
                        (context, index) =>
                            const Divider(height: 30, color: qBg),
                    itemBuilder: (context, index) {
                      // Offset by 3 to skip the podium winners
                      var data =
                          results[index + 3].data() as Map<String, dynamic>;
                      return _buildRankRow(index + 4, data);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> results) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(
        color: qPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (results.length >= 2) _podiumItem(results[1], 2),
          if (results.length >= 1) _podiumItem(results[0], 1),
          if (results.length >= 3) _podiumItem(results[2], 3),
        ],
      ),
    );
  }

  Widget _podiumItem(QueryDocumentSnapshot doc, int rank) {
    var data = doc.data() as Map<String, dynamic>;
    String name = (data['studentEmail'] as String).split('@')[0];
    int time = data['timeUsedSeconds'] ?? 0;

    return Column(
      children: [
        if (rank == 1)
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
        const SizedBox(height: 5),
        CircleAvatar(
          radius: rank == 1 ? 40 : 30,
          backgroundColor: qWhite.withOpacity(0.2),
          child: CircleAvatar(
            radius: rank == 1 ? 36 : 26,
            backgroundColor: qWhite,
            child: Text(
              "${rank == 1
                  ? '🥇'
                  : rank == 2
                  ? '🥈'
                  : '🥉'}",
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            color: qWhite,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          "${data['score']}/${data['total']}",
          style: TextStyle(color: qWhite.withOpacity(0.8), fontSize: 12),
        ),
        Text(
          "${time ~/ 60}m ${time % 60}s",
          style: TextStyle(color: qWhite.withOpacity(0.6), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRankRow(int rank, Map<String, dynamic> data) {
    String name = (data['studentEmail'] as String).split('@')[0];
    int time = data['timeUsedSeconds'] ?? 0;

    return Row(
      children: [
        Text(
          "#$rank",
          style: const TextStyle(fontWeight: FontWeight.bold, color: qGrey),
        ),
        const SizedBox(width: 20),
        CircleAvatar(
          backgroundColor: qBg,
          child: const Icon(Icons.person, color: qPrimary, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: qTextPrimary,
                ),
              ),
              Text(
                "${time ~/ 60}m ${time % 60}s",
                style: const TextStyle(color: qGrey, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          "${data['score']}/${data['total']}",
          style: const TextStyle(fontWeight: FontWeight.w900, color: qPrimary),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: qGrey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text("No participants yet!", style: TextStyle(color: qGrey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          "Database error. Please check if the composite index is active in Firebase Console.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
