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
  final _confirmPassController = TextEditingController();

  String _selectedRole = 'Student';
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      _showError("All fields are required");
      return;
    }
    if (_passController.text != _confirmPassController.text) {
      _showError("Passwords do not match");
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );
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
      if (!mounted) return;
      String nextRoute =
          _selectedRole == 'Teacher'
              ? '/teacher_dashboard'
              : '/student_dashboard';
      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: qPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text("Join Quizora", style: qTitleStyle),
              const SizedBox(height: 8),
              Text("Create an account", style: qSubTitleStyle),
              const SizedBox(height: 35),

              _buildInputContainer(
                child: TextField(
                  controller: _nameController,
                  decoration: _inputDeco("Full Name", Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco("Email Address", Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputContainer(
                child: TextField(
                  controller: _passController,
                  obscureText: _obscurePass,
                  decoration: _inputDeco(
                    "Password",
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: qGrey,
                      ),
                      onPressed:
                          () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputContainer(
                child: TextField(
                  controller: _confirmPassController,
                  obscureText: _obscureConfirm,
                  decoration: _inputDeco("Confirm Password", Icons.lock_reset),
                ),
              ),
              const SizedBox(height: 25),

              // Role Selector Label
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "I am a:",
                    style: qSubTitleStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard('Student', Icons.school_outlined),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildRoleCard('Teacher', Icons.co_present_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 35),

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _register,
                      child: Text("CREATE ACCOUNT", style: qButtonStyle),
                    ),
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: qGrey, fontSize: 15),
      prefixIcon: Icon(icon, color: qPrimary, size: 22),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? qPrimary : qWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? qPrimary : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? qWhite : qPrimary),
            const SizedBox(height: 5),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? qWhite : qTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
