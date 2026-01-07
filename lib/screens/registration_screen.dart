import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String _selectedRole = 'Student';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      //Create Auth Account
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      //Save Role & Name to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRole,
            'uid': cred.user!.uid,
            'createdAt': DateTime.now(),
          });

      //Navigate to appropriate dashboard
      if (!mounted) return;
      String nextRoute =
          _selectedRole == 'Teacher'
              ? '/teacher_dashboard'
              : '/student_dashboard';
      Navigator.pushReplacementNamed(context, nextRoute);
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
            Text("Join Quizora", style: qTitleStyle),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedRole,
              isExpanded: true,
              items:
                  ['Student', 'Teacher']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: qBlue)
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qBlue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _register,
                  child: const Text(
                    "REGISTER",
                    style: TextStyle(color: qWhite),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
