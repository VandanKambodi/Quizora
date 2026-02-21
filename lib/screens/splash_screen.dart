import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import 'intro_slider.dart';

bool isFirstLaunch = true; // session based only

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    _start();
  }

  void _start() async {
    // Shorter, snappier delay
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _goToDashboard(user);
    } else {
      if (isFirstLaunch) {
        isFirstLaunch = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroSlider()),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _goToDashboard(User user) async {
    try {
      var doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists && mounted) {
        String role = doc['role'] ?? 'Student';
        Navigator.pushReplacementNamed(
          context,
          role == 'Teacher' ? '/teacher_dashboard' : '/student_dashboard',
        );
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              qPrimaryLight, // Spotlight color
              qPrimary, // Brand color
              qPrimaryDark, // Deep edges
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: qWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: qBlack.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: qWhite.withOpacity(0.5),
                          blurRadius: 1,
                          spreadRadius: -5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/quizora-nbg.png',
                      width: 120,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "QUIZORA",
                    style: qTitleStyle.copyWith(
                      color: qWhite,
                      letterSpacing: 6,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: qWhite.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Learn • Compete • Grow",
                      style: qSubTitleStyle.copyWith(
                        color: qWhite,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Modern Loader
                  const SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(qWhite),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
