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
  bool _obscurePassword = true; // For password visibility toggle

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
        backgroundColor: Colors.redAccent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'app_logo',
                child: Image.asset('assets/images/quizora-nbg.png', width: 140),
              ),
              const SizedBox(height: 25),

              Text("Welcome Back", style: qTitleStyle),
              const SizedBox(height: 8),
              Text("Sign in to continue to Quizora", style: qSubTitleStyle),
              const SizedBox(height: 40),

              _buildTextField(
                controller: _emailController,
                hintText: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _passController,
                hintText: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                onSuffixTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: qPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator(color: qPrimary)
                  : Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: qPrimary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: qPrimary,
                        foregroundColor: qWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _login,
                      child: Text("LOGIN", style: qButtonStyle),
                    ),
                  ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New user? ", style: qSubTitleStyle),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      "Create an account",
                      style: qSubTitleStyle.copyWith(
                        color: qPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: qTextPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: qGrey, fontSize: 15),
          prefixIcon: Icon(icon, color: qPrimary, size: 22),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: qGrey,
                    ),
                    onPressed: onSuffixTap,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
