import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants.dart';
import '../result_screen.dart';
import 'quiz_leaderboard.dart';

class QuizAnalyticsScreen extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const QuizAnalyticsScreen({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  State<QuizAnalyticsScreen> createState() => _QuizAnalyticsScreenState();
}

class _QuizAnalyticsScreenState extends State<QuizAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List assignedEmails = widget.quizData['assignedStudents'] ?? [];

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
          widget.quizData['title'],
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
                          quizId: widget.quizId,
                          quizTitle: widget.quizData['title'],
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
                .where('quizId', isEqualTo: widget.quizId)
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
          int pendingCount = total - done;
          double completionRate = total > 0 ? (done / total) : 0;

          return Column(
            children: [
              _buildHeaderStats(total, done, completionRate),

              TabBar(
                controller: _tabController,
                labelColor: qPrimary,
                unselectedLabelColor: qGrey,
                indicatorColor: qPrimary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Finished"),
                  Tab(text: "Pending"),
                  Tab(text: "Stats"),
                ],
              ),

              if (_tabController.index != 2) _buildSearchBar(),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDoneList(finishedDocs),
                    _buildPendingList(assignedEmails, finishedEmails),
                    _buildStatisticsTab(done, pendingCount, finishedDocs),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: qWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: qBlack.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged:
              (value) => setState(() => _searchQuery = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search student email...",
            hintStyle: const TextStyle(color: qGrey, fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: qPrimary, size: 25),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneList(List<QueryDocumentSnapshot> docs) {
    final filteredDocs =
        docs.where((doc) {
          String email =
              (doc.data() as Map<String, dynamic>)['studentEmail'] ?? "";
          return email.toLowerCase().contains(_searchQuery);
        }).toList();

    if (filteredDocs.isEmpty)
      return _buildEmptyState("No matching students found", Icons.search_off);

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        var data = filteredDocs[index].data() as Map<String, dynamic>;
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
    var pending =
        assigned.where((email) {
          bool isPending = !finished.contains(email);
          bool matchesSearch = email.toString().toLowerCase().contains(
            _searchQuery,
          );
          return isPending && matchesSearch;
        }).toList();

    if (pending.isEmpty)
      return _buildEmptyState(
        "No pending students found",
        Icons.person_search_outlined,
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

  Widget _buildScoreBarChart(List<QueryDocumentSnapshot> docs) {
    int low = 0, mid = 0, high = 0;
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
            _barGroup(0, low.toDouble(), Colors.redAccent),
            _barGroup(1, mid.toDouble(), Colors.orangeAccent),
            _barGroup(2, high.toDouble(), Colors.greenAccent),
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

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: color, width: 20)],
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
