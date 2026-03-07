import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import 'dart:convert';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditDetailsSheet(
    BuildContext context,
    Map<String, dynamic> currentData,
  ) {
    final nameController = TextEditingController(
      text: currentData['name'] ?? "",
    );
    final bioController = TextEditingController(text: currentData['bio'] ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 25,
              right: 25,
            ),
            decoration: const BoxDecoration(
              color: qWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: qBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Edit Personal Details",
                  style: qTitleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  "Display Name",
                  nameController,
                  Icons.person_outline,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  "Bio/Status",
                  bioController,
                  Icons.info_outline,
                  maxLines: 2,
                ),

                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    String uid = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({
                          'name': nameController.text.trim(),
                          'bio': bioController.text.trim(),
                        });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Profile updated successfully!"),
                      ),
                    );
                  },
                  child: const Text(
                    "SAVE CHANGES",
                    style: TextStyle(
                      color: qWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: qPrimary, size: 20),
        filled: true,
        fillColor: qBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: qBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String displayName =
              userData['name'] ?? user?.email?.split('@')[0] ?? 'User';
          String bio = userData['bio'] ?? "Quizora Enthusiast";
          String? base64String = userData['profileItem'];

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    _buildHeader(context),
                    Positioned(
                      bottom: -50,
                      child: _buildAvatarStack(base64String),
                    ),
                  ],
                ),
                const SizedBox(height: 65),

                Text(
                  displayName.toUpperCase(),
                  style: qTitleStyle.copyWith(
                    fontSize: 24,
                    color: qTextPrimary,
                  ),
                ),
                Text(
                  bio,
                  style: qSubTitleStyle.copyWith(fontSize: 14, color: qGrey),
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
                          onTap: () => _showEditDetailsSheet(context, userData),
                        ),
                        _buildDivider(),
                        _profileItem(
                          Icons.alternate_email_rounded,
                          "Email (Verified)",
                          trailing: const Text(
                            "Locked",
                            style: TextStyle(color: qGrey, fontSize: 12),
                          ),
                        ),
                      ]),

                      const SizedBox(height: 25),
                      _buildSectionLabel("SUPPORT"),
                      _buildMenuContainer([
                        _profileItem(Icons.help_outline_rounded, "Need Help?"),
                        _buildDivider(),
                        _profileItem(
                          Icons.info_outline_rounded,
                          "About Quizora",
                        ),
                      ]),
                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: qPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text(
              "Profile",
              style: TextStyle(
                color: qWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: qWhite, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
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
            child: _circleIcon(Icons.camera_alt_rounded),
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: qPrimary, shape: BoxShape.circle),
      child: Icon(icon, color: qWhite, size: 20),
    );
  }

  Widget _profileItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
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
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: qGrey, size: 20),
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
}
