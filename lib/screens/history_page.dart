import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import 'result_screen.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: qBg,
      body: CustomScrollView(
        slivers: [
          // Premium Glassmorphic Header
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: qPrimary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Performance History",
                style: qTitleStyle.copyWith(color: qWhite, fontSize: 18),
              ),
              background: Container(color: qPrimary),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('results')
                    .where('studentEmail', isEqualTo: email)
                    .orderBy('submittedAt', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return _buildErrorState();
              if (!snapshot.hasData) return _buildLoadingState();

              final results = snapshot.data!.docs;
              if (results.isEmpty) return _buildEmptyState();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var data = results[index].data() as Map<String, dynamic>;
                    return _buildHistoryCard(context, data, index);
                  }, childCount: results.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    int score = data['score'] ?? 0;
    int total = data['total'] ?? 0;
    double percent = total > 0 ? (score / total) * 100 : 0;

    String dateStr = "Recent";
    if (data['submittedAt'] != null) {
      DateTime dt = (data['submittedAt'] as Timestamp).toDate();
      dateStr = DateFormat('MMM d, yyyy').format(dt);
    }

    // Dynamic color based on performance
    Color statusColor =
        percent >= 80
            ? Colors.greenAccent.shade700
            : (percent >= 50 ? qPrimary : Colors.orangeAccent);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {
              List<dynamic> reviewList =
                  data['review'] != null
                      ? List<dynamic>.from(data['review'])
                      : [];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ResultScreen(
                        score: score,
                        total: total,
                        reviewData: reviewList,
                      ),
                ),
              );
            },
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: statusColor,
                      size: 26,
                    ),
                  ),
                  title: Text(
                    data['quizTitle'] ?? "Quiz Result",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: qTextPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        _buildSmallBadge(Icons.calendar_today, dateStr),
                        const SizedBox(width: 12),
                        _buildSmallBadge(
                          Icons.analytics_outlined,
                          "$score/$total",
                        ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${percent.toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: qGrey,
                      ),
                    ],
                  ),
                ),
                // Performance mini-bar at the bottom of the card
                LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: qBg,
                  color: statusColor.withOpacity(0.6),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: qGrey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: qGrey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // State Builders
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 80,
              color: qGrey.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text("No records found", style: qSubTitleStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const SliverFillRemaining(
      child: Center(child: Text("Error fetching history")),
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator(color: qPrimary)),
    );
  }
}
