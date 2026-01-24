import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/database_service.dart';
import '../../constants.dart';

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({super.key});

  @override
  State<AddQuizPage> createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final _titleController = TextEditingController();
  final _timerController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();

  bool _isUploading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    final Uri url = Uri.parse(
      'https://quizora-c93f1.web.app/quiz_template.xlsx',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showError("Unable to open template link");
    }
  }

  Future<void> _createQuiz() async {
    if (_titleController.text.trim().isEmpty ||
        _timerController.text.trim().isEmpty) {
      _showError("Title and timer are required");
      return;
    }

    int? timer = int.tryParse(_timerController.text.trim());
    if (timer == null || timer <= 0) {
      _showError("Enter a valid timer");
      return;
    }

    setState(() => _isUploading = true);

    try {
      await DatabaseService().createFullQuiz(
        title: _titleController.text.trim(),
        timer: timer,
        description: _descController.text.trim(),
        category: _categoryController.text.trim(),
      );

      _showSuccess("Quiz created successfully");

      if (mounted) Navigator.pop(context);
    } catch (_) {
      _showError("Failed to create quiz");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quizora"), backgroundColor: qPrimary),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Create New Quiz",
                      textAlign: TextAlign.center,
                      style: qTitleStyle,
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Quiz Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _timerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Timer (Minutes)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: qPrimary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _downloadTemplate,
                      icon: const Icon(Icons.download, color: qWhite),
                      label: const Text(
                        "Download Excel Template",
                        style: TextStyle(color: qWhite),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _isUploading
                        ? const Center(
                          child: CircularProgressIndicator(color: qPrimary),
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: qPrimary,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _createQuiz,
                          child: const Text(
                            "Create Quiz",
                            style: TextStyle(
                              color: qWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
