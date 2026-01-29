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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizora"),
        backgroundColor: qPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: qWhite),
            onPressed: () async {
              await FirebaseAuth.instance
                  .signOut(); // Logs user out of Firebase
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

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Quizzes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(quiz['title']),
                        subtitle: Text(
                          "Time: ${quiz['timer']} mins | ${quiz['assignedStudents'].length} Students",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed:
                                  () => _showEditQuizDialog(
                                    context,
                                    quiz.id,
                                    quiz.data() as Map<String, dynamic>,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.group, color: qPrimary),
                              onPressed:
                                  () => _manageStudentsDialog(
                                    context,
                                    quiz.id,
                                    quiz['assignedStudents'],
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text("Delete Quiz"),
                                        content: const Text(
                                          "Are you sure you want to delete this quiz?\n\nThis action cannot be undone.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () async {
                                              await DatabaseService()
                                                  .deleteQuiz(quiz.id);
                                              if (context.mounted)
                                                Navigator.pop(context);

                                              // Success feedback
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Quiz deleted successfully",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.co_present,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                // Safely check if the field exists in the document map
                                Map<String, dynamic> data =
                                    quiz.data() as Map<String, dynamic>;
                                List<dynamic> collaborators =
                                    data.containsKey('collaborators')
                                        ? data['collaborators']
                                        : [];

                                _manageCollaboratorsDialog(
                                  context,
                                  quiz.id,
                                  collaborators,
                                );
                              },
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
            title: const Text("Add Teacher Collaborator"),
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
                  await DatabaseService().addCollaborator(
                    quizId,
                    controller.text,
                  );
                  if (context.mounted) Navigator.pop(context);
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
    List<dynamic> currentTeachers,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Manage Teacher Collaborators"),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showCollaboratorDialog(context, quizId),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Invite Teacher"),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentTeachers.length,
                      itemBuilder: (context, index) {
                        String email = currentTeachers[index];
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
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _editCollaboratorDialog(
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
                                            "Remove Collaborator",
                                          ),
                                          content: Text(
                                            "Are you sure you want to remove\n$email as a collaborator?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () async {
                                                await DatabaseService()
                                                    .removeCollaborator(
                                                      quizId,
                                                      email,
                                                    );

                                                if (context.mounted) {
                                                  Navigator.pop(
                                                    context,
                                                  ); // close dialog
                                                  Navigator.pop(
                                                    context,
                                                  ); // close manage collaborators dialog
                                                }

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Collaborator removed successfully",
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
                child: const Text("Close"),
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
