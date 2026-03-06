import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../services/profile_service.dart';
import 'exam_screen.dart';
import 'result_screen.dart';

class TriviaPost {
  final String question;
  final String category;

  TriviaPost({required this.question, required this.category});

  factory TriviaPost.fromJson(Map<String, dynamic> json) {
    return TriviaPost(
      // Cleans HTML entities like &quot; from API strings
      question: json['question']
          .toString()
          .replaceAll('&quot;', '"')
          .replaceAll('&#039;', "'")
          .replaceAll('&amp;', '&'),
      category: json['category'],
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  // --- API LOGIC ---
  Future<List<TriviaPost>> fetchExternalTrivia() async {
    const String apiUrl = "https://opentdb.com/api.php?amount=5&type=multiple";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List results = data['results'];
        return results.map((e) => TriviaPost.fromJson(e)).toList();
      } else {
        throw Exception("Server failure");
      }
    } catch (e) {
      throw Exception("Connection lost");
    }
  }

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
            _buildHeader(name),

            // DAILY TRIVIA SECTION (API)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 15),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "Daily Trivia",
                    style: qTitleStyle.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            _buildTriviaList(),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: qWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: qBlack.withOpacity(0.02), blurRadius: 10),
                  ],
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: qPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: qPrimary,
                  unselectedLabelColor: qGrey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [Tab(text: "Upcoming"), Tab(text: "Completed")],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
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

  Widget _buildHeader(String name) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
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
                    style: TextStyle(
                      color: qWhite.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${name[0].toUpperCase()}${name.substring(1)}",
                    style: const TextStyle(
                      color: qWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const CircleAvatar(
                      radius: 25,
                      backgroundColor: qWhite,
                      child: Icon(Icons.person, color: qPrimary),
                    );
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String? base64String =
                      userData.containsKey('profileItem')
                          ? userData['profileItem']
                          : null;

                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: qWhite,
                    backgroundImage:
                        base64String != null
                            ? MemoryImage(base64Decode(base64String))
                            : null,
                    child:
                        base64String == null
                            ? const Icon(
                              Icons.person_rounded,
                              color: qPrimary,
                              size: 30,
                            )
                            : null,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
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
                _headerStat("Learning", "Active"),
                Container(width: 1, height: 30, color: qWhite.withOpacity(0.2)),
                _headerStat("Quizora", "Student"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: qWhite, width: 5),
      ),
      child: const CircleAvatar(
        radius: 55,
        backgroundColor: qBg,
        child: Icon(Icons.person_rounded, size: 60, color: qPrimary),
      ),
    );
  }

  Widget _headerStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(color: qWhite, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: qWhite.withOpacity(0.6), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTriviaList() {
    return SizedBox(
      height: 140,
      child: FutureBuilder<List<TriviaPost>>(
        future: fetchExternalTrivia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: qPrimary, strokeWidth: 2),
            );
          }
          if (snapshot.hasError)
            return _buildTriviaPlaceholder("Unable to fetch trivia");

          final triviaList = snapshot.data ?? [];
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: triviaList.length,
            itemBuilder: (context, index) {
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 15, bottom: 10),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: qWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: qBlack.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      triviaList[index].category.toUpperCase(),
                      style: const TextStyle(
                        color: qPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      triviaList[index].question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: qTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilteredQuizList(String? email, {required bool isCompletedTab}) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('quizzes')
              .where('assignedStudents', arrayContains: email)
              .snapshots(),
      builder: (context, quizSnapshot) {
        if (!quizSnapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('results')
                  .where('studentEmail', isEqualTo: email)
                  .snapshots(),
          builder: (context, resultSnapshot) {
            if (!resultSnapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            List<String> finishedIds =
                resultSnapshot.data!.docs
                    .map((doc) => doc['quizId'] as String)
                    .toList();

            final displayQuizzes =
                quizSnapshot.data!.docs.where((doc) {
                  bool isDone = finishedIds.contains(doc.id);
                  return isCompletedTab ? isDone : !isDone;
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
                final quizDoc = displayQuizzes[index];
                final data = quizDoc.data() as Map<String, dynamic>;
                Map<String, dynamic>? result;
                if (isCompletedTab) {
                  result =
                      resultSnapshot.data!.docs
                              .firstWhere((doc) => doc['quizId'] == quizDoc.id)
                              .data()
                          as Map<String, dynamic>;
                }
                return _buildModernQuizCard(
                  context,
                  quizDoc.id,
                  data,
                  isCompletedTab,
                  result,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildModernQuizCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    bool isDone,
    Map<String, dynamic>? res,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 8,
                color: isDone ? Colors.greenAccent.shade700 : qPrimary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                                fontSize: 17,
                                color: qTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (isDone)
                              Text(
                                "Score: ${res?['score']}/${res?['total']}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: qGrey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${data['timer']} Mins",
                                    style: const TextStyle(
                                      color: qGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      _buildStartReviewButton(context, id, data, isDone, res),
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

  Widget _buildStartReviewButton(
    BuildContext context,
    String qId,
    Map<String, dynamic> data,
    bool isDone,
    Map<String, dynamic>? res,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDone ? qBg : qPrimary,
        foregroundColor: isDone ? qPrimary : qWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {
        if (isDone) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultScreen(
                    score: res!['score'],
                    total: res['total'],
                    reviewData: res['review'],
                  ),
            ),
          );
        } else {
          if (!(data['isActive'] ?? true)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Quiz is currently closed.")),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamScreen(quizId: qId, quizData: data),
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

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 50,
            color: qGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(msg, style: qSubTitleStyle.copyWith(color: qGrey)),
        ],
      ),
    );
  }

  Widget _buildTriviaPlaceholder(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: qGrey, fontSize: 12)),
    );
  }
}
