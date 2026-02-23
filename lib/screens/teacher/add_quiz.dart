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
        margin: const EdgeInsets.all(20),
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
        margin: const EdgeInsets.all(20),
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
      backgroundColor: qBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("QUIZ INFORMATION"),
                  const SizedBox(height: 15),

                  // Form Container
                  _buildFormCard(),

                  const SizedBox(height: 25),
                  _buildSectionLabel("QUESTIONS TEMPLATE"),
                  const SizedBox(height: 15),

                  // Template Download Card
                  _buildTemplateCard(),

                  const SizedBox(height: 40),

                  // Action Button
                  _isUploading
                      ? const Center(
                        child: CircularProgressIndicator(color: qPrimary),
                      )
                      : _buildSubmitButton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: qPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: qWhite, size: 20),
          ),
          const Expanded(
            child: Text(
              "Configure Quiz",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: qWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balancing back button
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          _buildTextField(
            _titleController,
            "Quiz Title",
            Icons.title_rounded,
            false,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            _timerController,
            "Timer (Minutes)",
            Icons.timer_outlined,
            true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            _categoryController,
            "Category (e.g. Science)",
            Icons.category_outlined,
            false,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            _descController,
            "Short Description",
            Icons.description_outlined,
            false,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    bool isNum, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: qPrimary, size: 20),
        filled: true,
        fillColor: qBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(fontSize: 14, color: qGrey),
      ),
    );
  }

  Widget _buildTemplateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: qPrimary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.table_view_rounded,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Excel Template",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Download & fill the questions",
                  style: TextStyle(color: qGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _downloadTemplate,
            icon: const Icon(
              Icons.download_for_offline_rounded,
              color: qPrimary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: qPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: qPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        onPressed: _createQuiz,
        child: const Text(
          "PUBLISH QUIZ",
          style: TextStyle(
            color: qWhite,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: qGrey,
      ),
    );
  }
}
