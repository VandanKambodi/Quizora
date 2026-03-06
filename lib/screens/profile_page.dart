import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import 'dart:convert';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.email?.split('@')[0] ?? 'User';

    return Scaffold(
      backgroundColor: qBg,
      body: SingleChildScrollView(
        // Added to fix Bottom Overflow
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: qPrimary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: qWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: qWhite,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .snapshots(),
                    builder: (context, snapshot) {
                      // Safety check for null data or non-existent document
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return _buildAvatarStack(null);
                      }

                      var userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      String? base64String =
                          userData.containsKey('profileItem')
                              ? userData['profileItem']
                              : null;

                      return _buildAvatarStack(base64String);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 65),
            Text(
              name.toUpperCase(),
              style: qTitleStyle.copyWith(fontSize: 24, color: qTextPrimary),
            ),
            Text(
              user?.email ?? "email@example.com",
              style: qSubTitleStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("ACCOUNT"),
                  _buildMenuContainer([
                    _profileItem(
                      Icons.person_outline_rounded,
                      "Personal Details",
                    ),
                    _buildDivider(),
                    _profileItem(Icons.history_rounded, "My Certificates"),
                  ]),
                  const SizedBox(height: 25),
                  _buildSectionLabel("SUPPORT"),
                  _buildMenuContainer([
                    _profileItem(Icons.help_outline_rounded, "Need Help?"),
                    _buildDivider(),
                    _profileItem(Icons.lock_outline_rounded, "Privacy Policy"),
                    _buildDivider(),
                    _profileItem(Icons.info_outline_rounded, "About Quizora"),
                  ]),
                  const SizedBox(height: 40),
                  _buildLogoutButton(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(String? base64String) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: qWhite, width: 5),
            boxShadow: [
              BoxShadow(color: qBlack.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: qBg,
            backgroundImage:
                base64String != null
                    ? MemoryImage(base64Decode(base64String))
                    : null,
            child:
                base64String == null
                    ? const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: qPrimary,
                    )
                    : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => ProfileService().updateProfileImage(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: qPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: qWhite,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      icon: const Icon(Icons.logout_rounded),
      label: const Text(
        "LOGOUT ACCOUNT",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: qGrey.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 60, color: qBg);

  Widget _profileItem(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: qPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: qPrimary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: qTextPrimary,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: qGrey, size: 20),
    );
  }

  Widget _avatarWrapper(String? base64String) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: qWhite,
          backgroundImage:
              base64String != null
                  ? MemoryImage(base64Decode(base64String))
                  : null,
          child:
              base64String == null ? const Icon(Icons.person, size: 50) : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () async {
              await ProfileService().updateProfileImage();
            },
            child: const CircleAvatar(
              radius: 18,
              child: Icon(Icons.camera_alt, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBackground() {
    return Container(height: 220, width: double.infinity, color: qPrimary);
  }
}
