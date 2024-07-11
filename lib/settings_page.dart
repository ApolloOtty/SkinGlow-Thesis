import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text('Settings Page Content'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Handle logout action
              // For example, you can show a dialog to confirm logout
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Perform logout actions, such as clearing user session
                          // Clear user ID from SharedPreferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.remove('userid');

                          // Navigate back to the previous screen
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
