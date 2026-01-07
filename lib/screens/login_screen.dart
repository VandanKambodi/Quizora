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

      // Check Firestore for Role
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/images/quizora-nbg.png', width: 120),
            const SizedBox(height: 20),
            Text("Welcome Back", style: qTitleStyle.copyWith(color: qBlack)),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: qBlue)
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qBlue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _login,
                  child: const Text("LOGIN", style: TextStyle(color: qWhite)),
                ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text("New user? Create an account"),
            ),
          ],
        ),
      ),
    );
  }
}
