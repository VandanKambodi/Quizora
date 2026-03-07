import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../constants.dart';
import 'add_quiz.dart';
import 'dart:convert';
import 'quiz_leaderboard.dart';
import 'quiz_analytics_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String name = currentUser?.email?.split('@')[0] ?? 'Teacher';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: qBg,
        floatingActionButton: FloatingActionButton.extended(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddQuizPage()),
              ),
          backgroundColor: qPrimary,
          icon: const Icon(Icons.add_rounded, color: qWhite),
          label: const Text(
            "CREATE QUIZ",
            style: TextStyle(
              color: qWhite,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Manage Your Quizzes",
                              style: qSubTitleStyle.copyWith(
                                color: qWhite.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${name[0].toUpperCase()}${name.substring(1)}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: qTitleStyle.copyWith(
                                color: qWhite,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),

                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: qWhite.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: qBlack.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: qWhite,
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/images/quizora-wbg.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: qWhite.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: qWhite,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: qPrimary,
                      unselectedLabelColor: qWhite,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: "Active Quizzes"),
                        Tab(text: "Inactive"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFilteredQuizList(currentUser, showActive: true),
                  _buildFilteredQuizList(currentUser, showActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredQuizList(User? user, {required bool showActive}) {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getTeacherQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: qPrimary),
          );
        }
        final allDocs = snapshot.data?.docs ?? [];
        final filteredDocs =
            allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              bool status = data['isActive'] ?? true;
              return showActive ? (status == true) : (status == false);
            }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState(
            showActive
                ? "No live quizzes currently"
                : "No inactive quizzes found",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var quiz = filteredDocs[index];
            Map<String, dynamic> data = quiz.data() as Map<String, dynamic>;
            return _buildPremiumQuizCard(
              context,
              quiz.id,
              data,
              data['createdBy'] == user?.uid,
              user?.email ?? "",
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumQuizCard(
    BuildContext context,
    String quizId,
    Map<String, dynamic> data,
    bool isOwner,
    String myEmail,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getQuizSummary(quizId),
      builder: (context, summarySnap) {
        int completedCount =
            summarySnap.hasData ? summarySnap.data!.docs.length : 0;
        int assignedCount = (data['assignedStudents'] as List).length;
        bool isActive = data['isActive'] ?? true;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: qWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: qBlack.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.grey.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Text(
                  isActive ? "● LIVE SESSION" : "○ SESSION PAUSED",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: qWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: qTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Done: $completedCount / $assignedCount • ${data['timer']} mins",
                                style: qSubTitleStyle.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isActive,
                          activeColor: qPrimary,
                          onChanged:
                              (val) => DatabaseService().toggleQuizStatus(
                                quizId,
                                val,
                              ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          Icons.edit_note_rounded,
                          "Edit",
                          Colors.orange,
                          () => _showEditQuizDialog(context, quizId, data),
                        ),
                        _buildQuickAction(
                          Icons.group_add_rounded,
                          "Students",
                          qPrimary,
                          () => _manageStudentsDialog(
                            context,
                            quizId,
                            data['assignedStudents'],
                          ),
                        ),
                        _buildQuickAction(
                          Icons.share_rounded,
                          "Staff",
                          Colors.teal,
                          () => _manageCollaboratorsDialog(
                            context,
                            quizId,
                            data,
                            isOwner,
                            myEmail,
                          ),
                        ),
                        _buildQuickAction(
                          isOwner
                              ? Icons.delete_sweep_rounded
                              : Icons.logout_rounded,
                          isOwner ? "Delete" : "Leave",
                          Colors.redAccent,
                          () => _handleDeleteOrLeave(
                            context,
                            quizId,
                            isOwner,
                            myEmail,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: qWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.logout_rounded, color: qWhite, size: 20),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 60,
            color: qGrey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(message, style: qSubTitleStyle),
        ],
      ),
    );
  }

  void _handleDeleteOrLeave(
    BuildContext context,
    String quizId,
    bool isOwner,
    String? userEmail,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(isOwner ? "Delete Quiz" : "Leave Quiz"),
            content: Text(
              isOwner
                  ? "This action is permanent and will remove the quiz for everyone."
                  : "Remove this quiz from your dashboard?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (isOwner)
                    await DatabaseService().deleteQuiz(quizId);
                  else
                    await DatabaseService().removeCollaborator(
                      quizId,
                      userEmail!,
                    );
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isOwner ? "Delete" : "Leave"),
              ),
            ],
          ),
    );
  }

  void _showEditQuizDialog(
    BuildContext context,
    String quizId,
    Map<String, dynamic> currentData,
  ) {
    final titleEdit = TextEditingController(text: currentData['title']);
    final timerEdit = TextEditingController(
      text: currentData['timer'].toString(),
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Edit Quiz"),
            content: SingleChildScrollView(
              // PREVENTS KEYBOARD OVERFLOW
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleEdit,
                    decoration: InputDecoration(
                      labelText: "Quiz Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: timerEdit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Timer (mins)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseService().updateQuizDetails(quizId, {
                    'title': titleEdit.text,
                    'timer': int.parse(timerEdit.text),
                  });
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _manageStudentsDialog(
    BuildContext context,
    String quizId,
    List<dynamic> currentStudents,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Manage Students"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAssignDialog(context, quizId),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Assign New"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: qPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Divider(height: 30),
                  Flexible(
                    // PREVENTS OVERFLOW IN LIST
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentStudents.length,
                      itemBuilder: (context, index) {
                        String email = currentStudents[index];
                        return ListTile(
                          title: Text(
                            email,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                onPressed:
                                    () => _editStudentDialog(
                                      context,
                                      quizId,
                                      email,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () async {
                                  await DatabaseService().removeStudentFromQuiz(
                                    quizId,
                                    email,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  void _manageCollaboratorsDialog(
    BuildContext context,
    String quizId,
    Map<String, dynamic> data,
    bool isOwner,
    String myEmail,
  ) {
    List<dynamic> collaborators = data['collaborators'] ?? [];
    String ownerId = data['createdBy'];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Teachers Access"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOwner)
                    ElevatedButton.icon(
                      onPressed: () => _showCollaboratorDialog(context, quizId),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text("Invite Teacher"),
                    ),
                  const Divider(),
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(ownerId)
                            .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const Text("Loading...");
                      return ListTile(
                        leading: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        title: Text(
                          userSnap.data!.get('email'),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: const Text(
                          "Main Creator",
                          style: TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: collaborators.length,
                      itemBuilder: (context, index) {
                        String email = collaborators[index];
                        return ListTile(
                          title: Text(
                            email,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing:
                              (isOwner || email == myEmail)
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    onPressed: () async {
                                      await DatabaseService()
                                          .removeCollaborator(quizId, email);
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    },
                                  )
                                  : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          ),
    );
  }

  void _showAssignDialog(BuildContext context, String quizId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Assign Students"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Emails (comma separated)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  List<String> emails =
                      controller.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  var quizDoc =
                      await FirebaseFirestore.instance
                          .collection('quizzes')
                          .doc(quizId)
                          .get();
                  List existingStudents =
                      quizDoc.data()?['assignedStudents'] ?? [];

                  List<String> validStudents = [];
                  String errorMessage = "";

                  for (String email in emails) {
                    if (existingStudents.contains(email)) {
                      errorMessage = "Email already exists in this quiz.";
                      continue;
                    }

                    var userSnap =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: email)
                            .where('role', isEqualTo: 'Student')
                            .get();

                    if (userSnap.docs.isNotEmpty) {
                      validStudents.add(email);
                    } else {
                      errorMessage =
                          "This email is not registered as a Student.";
                    }
                  }

                  if (validStudents.isNotEmpty) {
                    await DatabaseService().assignStudents(
                      quizId,
                      validStudents,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(errorMessage),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Assign"),
              ),
            ],
          ),
    );
  }

  void _showCollaboratorDialog(BuildContext context, String quizId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Invite Teacher"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Teacher Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String email = controller.text.trim();
                  final currentUserEmail =
                      FirebaseAuth.instance.currentUser?.email;

                  if (email == currentUserEmail) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "You are the owner. You don't need to add yourself to staff.",
                        ),
                      ),
                    );
                    return;
                  }

                  var quizDoc =
                      await FirebaseFirestore.instance
                          .collection('quizzes')
                          .doc(quizId)
                          .get();
                  List existingStaff = quizDoc.data()?['collaborators'] ?? [];
                  String creatorId = quizDoc.data()?['createdBy'] ?? "";

                  if (existingStaff.contains(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("This teacher is already in your staff."),
                      ),
                    );
                    return;
                  }

                  var teacherSnap =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: email)
                          .where('role', isEqualTo: 'Teacher')
                          .get();

                  if (teacherSnap.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "This email is not registered as a Teacher.",
                        ),
                      ),
                    );
                    return;
                  }

                  await DatabaseService().addCollaborator(quizId, email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Staff member added successfully!"),
                      ),
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  void _editStudentDialog(
    BuildContext context,
    String quizId,
    String oldEmail,
  ) {
    final editController = TextEditingController(text: oldEmail);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Edit Student"),
            content: TextField(
              controller: editController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseService().updateStudentEmail(
                    quizId,
                    oldEmail,
                    editController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _showProfileMenu(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: qWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: qBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Teacher Account",
                  style: qSubTitleStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: qPrimary,
                  ),
                  title: Text(
                    "${name[0].toUpperCase()}${name.substring(1)}'s Profile",
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Logout Session",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted)
                      Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }
}
