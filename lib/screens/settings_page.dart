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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Notification Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SwitchListTile(
            title: const Text("New Quiz Alerts"),
            subtitle: const Text("Get notified when a teacher assigns a quiz"),
            value: _notifEnabled,
            activeColor: qPrimary,
            onChanged: (val) => setState(() => _notifEnabled = val),
          ),
          const Divider(),
          const Text(
            "Account Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _darkMode,
            activeColor: qPrimary,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Privacy Policy"),
            onTap: () {}, // Link to policy
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Need Help?"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
