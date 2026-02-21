import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import 'exam_screen.dart';
import 'result_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.email?.split('@')[0] ?? 'Student';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: qBg,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
              decoration: const BoxDecoration(
                color: qPrimary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: qSubTitleStyle.copyWith(
                              color: qWhite.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${name[0].toUpperCase()}${name.substring(1)}",
                            style: qTitleStyle.copyWith(
                              color: qWhite,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Glassmorphism Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: qWhite.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: qWhite.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat("Learning", "Active"),
                        Container(
                          height: 30,
                          width: 1,
                          color: qWhite.withOpacity(0.3),
                        ),
                        _buildHeaderStat("Quizora", "Student"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    indicatorColor: qWhite,
                    indicatorWeight: 3,
                    labelColor: qWhite,
                    unselectedLabelColor: qWhite.withOpacity(0.6),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [Tab(text: "Upcoming"), Tab(text: "Completed")],
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildFilteredQuizList(user?.email, isCompletedTab: false),
                  _buildFilteredQuizList(user?.email, isCompletedTab: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FILTERING QUIZZES BY STATUS
  Widget _buildFilteredQuizList(String? email, {required bool isCompletedTab}) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('quizzes')
              .where('assignedStudents', arrayContains: email)
              .snapshots(),
      builder: (context, quizSnapshot) {
        if (!quizSnapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: qPrimary),
          );

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('results')
                  .where('studentEmail', isEqualTo: email)
                  .snapshots(),
          builder: (context, resultSnapshot) {
            if (!resultSnapshot.hasData)
              return const Center(
                child: CircularProgressIndicator(color: qPrimary),
              );

            List<String> finishedQuizIds =
                resultSnapshot.data!.docs
                    .map((doc) => doc['quizId'] as String)
                    .toList();

            final displayQuizzes =
                quizSnapshot.data!.docs.where((doc) {
                  bool alreadyDone = finishedQuizIds.contains(doc.id);
                  return isCompletedTab ? alreadyDone : !alreadyDone;
                }).toList();

            if (displayQuizzes.isEmpty) {
              return _buildEmptyState(
                isCompletedTab
                    ? "No completed quizzes yet"
                    : "All quizzes caught up!",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: displayQuizzes.length,
              itemBuilder: (context, index) {
                final data =
                    displayQuizzes[index].data() as Map<String, dynamic>;
                final quizId = displayQuizzes[index].id;

                Map<String, dynamic>? resultData;
                if (isCompletedTab) {
                  resultData =
                      resultSnapshot.data!.docs
                              .firstWhere((doc) => doc['quizId'] == quizId)
                              .data()
                          as Map<String, dynamic>;
                }

                return _buildPerfectQuizCard(
                  context,
                  quizId,
                  data,
                  isCompletedTab,
                  resultData,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPerfectQuizCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    bool isDone,
    Map<String, dynamic>? resultData,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: isDone ? Colors.green : qPrimary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: qTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isDone)
                              Text(
                                "Score: ${resultData?['score']}/${resultData?['total']}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              _buildIconInfo(
                                Icons.timer_outlined,
                                "${data['timer']} min",
                              ),
                          ],
                        ),
                      ),
                      _buildDynamicButton(
                        context,
                        id,
                        data,
                        isDone,
                        resultData,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicButton(
    BuildContext context,
    String quizId,
    Map<String, dynamic> data,
    bool isDone,
    Map<String, dynamic>? resultData,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDone ? qBg : qPrimary,
        foregroundColor: isDone ? qPrimary : qWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {
        if (isDone) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultScreen(
                    score: resultData!['score'],
                    total: resultData['total'],
                    reviewData: resultData['review'],
                  ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamScreen(quizId: quizId, quizData: data),
            ),
          );
        }
      },
      child: Text(
        isDone ? "Review" : "Start",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String sub) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: qWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          sub,
          style: TextStyle(color: qWhite.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: qGrey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: qGrey, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.coffee_outlined, size: 50, color: qGrey.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(msg, style: qSubTitleStyle),
        ],
      ),
    );
  }
}
