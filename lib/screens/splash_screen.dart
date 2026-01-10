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
      duration: const Duration(milliseconds: 1200),
    );

    _fade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scale = Tween(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _start();
  }

  void _start() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _goToDashboard(user);
    }

    else {
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
    var doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists && doc['role'] == 'Teacher') {
      Navigator.pushReplacementNamed(context, '/teacher_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/student_dashboard');
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [qPrimary, qPrimaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: qWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/quizora-nbg.png',
                      width: 110,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Text(
                    "QUIZORA",
                    style: qTitleStyle.copyWith(
                      color: qWhite,
                      letterSpacing: 3,
                      fontSize: 34,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Learn • Compete • Grow",
                    style: qSubTitleStyle.copyWith(
                      color: qWhite.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 45),

                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: qWhite,
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
