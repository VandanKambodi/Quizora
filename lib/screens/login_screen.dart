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
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showError("Email and password are required");
      return;
    }

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
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed";

      if (e.code == 'user-not-found') {
        msg = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        msg = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        msg = "Invalid email format";
      } else if (e.code == 'network-request-failed') {
        msg = "No internet connection";
      } else if (e.code == 'too-many-requests') {
        msg = "Too many attempts. Try again later";
      } else {
        msg = "Invalid email or password";
      }

      _showError(msg);
    } catch (e) {
      _showError("Something went wrong. Try again");
    }

    setState(() => _isLoading = false);
  }

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
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
