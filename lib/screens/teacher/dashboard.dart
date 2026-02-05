import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_quiz.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizora"),
        backgroundColor: qPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: qWhite),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: qPrimary,
        child: const Icon(Icons.add, color: qWhite),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddQuizPage()),
            ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "My Quizzes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getTeacherQuizzes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var quiz = docs[index];
                    Map<String, dynamic> data =
                        quiz.data() as Map<String, dynamic>;
                    String currentUserEmail = currentUser?.email ?? "";

                    // Permission logic: Are you the owner or an invited collaborator?
                    bool isOwner = data['createdBy'] == currentUser?.uid;
                    List<dynamic> collaborators = data['collaborators'] ?? [];
                    bool isCollaborator = collaborators.contains(
                      currentUserEmail,
                    );
                    bool hasPermission =
                        isOwner || isCollaborator;

                    return
                    Card(
                      elevation: 4, // Makes the card pop
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  isOwner ? Icons.star : Icons.people,
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Time: ${data['timer']} mins | ${data['assignedStudents'].length} Students",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Divider(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Workable Edit Button
                                _buildActionButton(
                                  Icons.edit,
                                  "Edit",
                                  Colors.orange,
                                  () => _showEditQuizDialog(
                                    context,
                                    quiz.id,
                                    data,
                                  ),
                                ),
                                // Manage Students
                                _buildActionButton(
                                  Icons.group,
                                  "Students",
                                  qPrimary,
                                  () => _manageStudentsDialog(
                                    context,
                                    quiz.id,
                                    data['assignedStudents'],
                                  ),
                                ),
                                // Manage Teachers
                                _buildActionButton(
                                  Icons.co_present,
                                  "Teachers",
                                  Colors.green,
                                  () => _manageCollaboratorsDialog(
                                    context,
                                    quiz.id,
                                    data,
                                    isOwner,
                                    currentUserEmail,
                                  ),
                                ),
                                // Delete or Leave
                                _buildActionButton(
                                  isOwner ? Icons.delete : Icons.exit_to_app,
                                  isOwner ? "Delete" : "Leave",
                                  Colors.red,
                                  () => _handleDeleteOrLeave(
                                    context,
                                    quiz.id,
                                    isOwner,
                                    currentUserEmail,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for modern buttons
  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
            title: Text(isOwner ? "Delete Quiz" : "Leave Quiz"),
            content: Text(
              isOwner
                  ? "Are you sure? This will remove the quiz for everyone."
                  : "Are you sure you want to remove this quiz from your dashboard?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (isOwner) {
                    await DatabaseService().deleteQuiz(quizId);
                  } else {
                    await DatabaseService().removeCollaborator(
                      quizId,
                      userEmail!,
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isOwner ? "Quiz deleted" : "You left the quiz",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
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
            title: const Text("Edit Quiz Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleEdit,
                  decoration: const InputDecoration(labelText: "Quiz Title"),
                ),
                TextField(
                  controller: timerEdit,
                  decoration: const InputDecoration(labelText: "Timer (mins)"),
                  keyboardType: TextInputType.number,
                ),
              ],
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

  void _showAssignDialog(BuildContext context, String quizId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Assign Students"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter emails separated by commas",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    List<String> emails =
                        controller.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList();
                    await DatabaseService().assignStudents(quizId, emails);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    // Show the specific error (e.g., "Email belongs to a Teacher")
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll("Exception: ", ""),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
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
            title: const Text("Add Teacher"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Teacher Email"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await DatabaseService().addCollaborator(
                      quizId,
                      controller.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Teacher added successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
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

  void _editCollaboratorDialog(
    BuildContext context,
    String quizId,
    String oldEmail,
  ) {
    final editController = TextEditingController(text: oldEmail);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Teacher Email"),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(labelText: "New Email"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseService().updateCollaboratorEmail(
                    quizId,
                    oldEmail,
                    editController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context); // Close edit dialog
                    Navigator.pop(context); // Close manage dialog to refresh
                  }
                },
                child: const Text("Save"),
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
            title: const Text("Manage Teachers"),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: Column(
                children: [
                  // Only original owner can invite
                  if (isOwner)
                    ElevatedButton.icon(
                      onPressed: () => _showCollaboratorDialog(context, quizId),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text("Invite Teacher"),
                    ),
                  const Divider(),
                  // Fetch real email from Users collection
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(ownerId)
                            .get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData)
                        return const Text("Loading Owner...");
                      String ownerEmail = userSnap.data!.get('email');
                      return ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(ownerEmail),
                        subtitle: const Text("Main Creator (Locked)"),
                      );
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: collaborators.length,
                      itemBuilder: (context, index) {
                        String email = collaborators[index];
                        bool isMe = email == myEmail;

                        return ListTile(
                          title: Text(email),
                          trailing:
                              (isOwner || isMe)
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
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
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Manage Students"),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showAssignDialog(context, quizId),
                        icon: const Icon(Icons.add),
                        label: const Text("Add New Student"),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentStudents.length,
                          itemBuilder: (context, index) {
                            String email = currentStudents[index];
                            return ListTile(
                              title: Text(
                                email,
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
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
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                "Remove Student",
                                              ),
                                              content: Text(
                                                "Are you sure you want to remove\n$email from this quiz?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  onPressed: () async {
                                                    await DatabaseService()
                                                        .removeStudentFromQuiz(
                                                          quizId,
                                                          email,
                                                        );

                                                    if (context.mounted) {
                                                      Navigator.pop(
                                                        context,
                                                      ); // close dialog
                                                      Navigator.pop(
                                                        context,
                                                      ); // close manage students dialog
                                                    }

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Student removed successfully",
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Remove"),
                                                ),
                                              ],
                                            ),
                                      );
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
                    child: const Text("Done"),
                  ),
                ],
              );
            },
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
            title: const Text("Edit Student Email"),
            content: TextField(controller: editController),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await DatabaseService().updateStudentEmail(
                      quizId,
                      oldEmail,
                      editController.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    // Show error if email is a duplicate
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
