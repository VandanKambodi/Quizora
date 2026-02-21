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
      backgroundColor: qBg,
      // We remove the AppBar here because the Dashboard/History/Settings
      // now have their own custom-styled headers for a more premium look.
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, "Home", 0),
              _navItem(Icons.history_rounded, "History", 1),
              _navItem(Icons.settings_rounded, "Settings", 2),
              // Profile is treated as a Nav Item here for easier access
              _navItem(Icons.person_rounded, "Profile", 3),
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
          // Special case for Profile: Navigate to full page
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
            Icon(icon, color: isSelected ? qPrimary : qGrey, size: 26),
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
