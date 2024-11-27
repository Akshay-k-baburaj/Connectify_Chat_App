import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';
import '../pages/settings_page.dart';
import '../pages/search_user.dart'; // Import your SearchPage

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser(); // Get current logged-in user

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Drawer header with user profile info
              UserAccountsDrawerHeader(
                accountName: const SizedBox(), // Display the user's name
                accountEmail:
                    Text(user?.email ?? 'No Email'), // Display the user's email
                currentAccountPicture: CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(
                          user!.photoURL!) // User profile picture if available
                      : const AssetImage('assets/default_profile.png')
                          as ImageProvider, // Default profile image
                  child: user?.photoURL == null
                      ? const Icon(Icons.person,
                          size: 40) // Fallback to person icon if no image
                      : null,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Home list title
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("H O M E"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Search title
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("S E A R C H"),
                  leading: const Icon(Icons.search), // Search icon
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchPage()), // Navigate to SearchPage
                    );
                  },
                ),
              ),
              // Settings title
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("S E T T I N G S"),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ),
            ],
          ),

          // Logout list
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/connectify_logo.png",
                      height: 80,
                      width: 160,
                    ),
                  ],
                ),
                ListTile(
                  title: const Text("L O G O U T"),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    logout();
                    Navigator.pop(context); // Close the drawer after logout
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
