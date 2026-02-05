import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import '../constants.dart';

class StudentMainWrapper extends StatefulWidget {
  const StudentMainWrapper({super.key});

  @override
  State<StudentMainWrapper> createState() => _StudentMainWrapperState();
}

class _StudentMainWrapperState extends State<StudentMainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentDashboard(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quizora",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: qPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32, color: qWhite),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: qPrimary,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
