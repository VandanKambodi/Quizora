import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundColor: qPrimary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email?.split('@')[0].toUpperCase() ?? "USERNAME",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "Email not found",
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 40),
            _profileItem(Icons.help_outline, "Need Help?"),
            _profileItem(Icons.lock_outline, "Privacy Policy"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                },
                child: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: qPrimary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
