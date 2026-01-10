import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (userDoc.exists && mounted) {
        String role = userDoc['role'];
        Navigator.pushReplacementNamed(
          context,
          role == 'Teacher' ? '/teacher_dashboard' : '/student_dashboard',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/quizora-nbg.png', width: 120),
              const SizedBox(height: 20),
              Text(
                "Welcome Back",
                style: qTitleStyle.copyWith(color: qTextPrimary),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _passController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 25),

              _isLoading
                  ? const CircularProgressIndicator(color: qPrimary)
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: qPrimary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _login,
                    child: Text("LOGIN", style: qButtonStyle),
                  ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("New user? Create an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
