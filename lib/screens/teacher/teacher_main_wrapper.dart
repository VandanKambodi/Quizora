import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'all_results_page.dart';
import '../settings_page.dart';
import '../profile_page.dart';
import '../../constants.dart';

class TeacherMainWrapper extends StatefulWidget {
  const TeacherMainWrapper({super.key});

  @override
  State<TeacherMainWrapper> createState() => _TeacherMainWrapperState();
}

class _TeacherMainWrapperState extends State<TeacherMainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TeacherDashboard(),
    const AllResultsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      // Removed the top AppBar to let individual pages handle their own headers
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildModernNav(),
    );
  }

  Widget _buildModernNav() {
    return Container(
      decoration: BoxDecoration(
        color: qWhite,
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.dashboard_customize_rounded, "Quizzes", 0),
              _navItem(Icons.analytics_rounded, "Analytics", 1),
              _navItem(Icons.settings_suggest_rounded, "Settings", 2),
              _navItem(Icons.face_retouching_natural_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          // Profile is a full-page push
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? qPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? qPrimary : qGrey, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: qPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
