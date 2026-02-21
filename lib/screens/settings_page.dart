import 'package:flutter/material.dart';
import '../constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qBg,
      body: CustomScrollView(
        slivers: [
          // Using a SliverAppBar for that high-end "Apple Settings" feel
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: qPrimary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Settings",
                style: qTitleStyle.copyWith(color: qWhite, fontSize: 20),
              ),
              background: Container(color: qPrimary),
            ),
          ),

          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              children: [
                _buildSectionHeader("Notifications"),
                _buildSettingsGroup([
                  _buildSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: "New Quiz Alerts",
                    subtitle: "Instantly know when a quiz is live",
                    value: _notifEnabled,
                    onChanged: (val) => setState(() => _notifEnabled = val),
                  ),
                ]),

                const SizedBox(height: 30),

                _buildSectionHeader("Personalization"),
                _buildSettingsGroup([
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    subtitle: "Easier on the eyes at night",
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),
                ]),

                const SizedBox(height: 30),

                _buildSectionHeader("Support & Legal"),
                _buildSettingsGroup([
                  _buildActionTile(
                    icon: Icons.shield_outlined,
                    title: "Privacy Policy",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.help_center_outlined,
                    title: "Help Center",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.info_outline_rounded,
                    title: "About Quizora",
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 25),

                Center(
                  child: Text(
                    "Quizora v1.0.2",
                    style: qSubTitleStyle.copyWith(fontSize: 12, color: qGrey),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: qSubTitleStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: qGrey.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: qWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: qBlack.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Container(
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
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: qTextPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: qSubTitleStyle.copyWith(fontSize: 12)),
      value: value,
      activeColor: qPrimary,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
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
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: qTextPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: qGrey,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: qBg.withOpacity(0.5),
    );
  }
}
