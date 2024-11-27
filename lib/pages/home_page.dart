import 'package:chat_service/services/auth/auth_service.dart';
import 'package:chat_service/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import '../components/user_tile.dart';
import 'chat_page.dart';
import 'search_user.dart'; // Import your SearchPage

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // Search icon in AppBar
            onPressed: () {
              // Navigate to SearchPage when the search icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // Build user list except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading users"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if there are no users available
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users available"));
        }

        // Map each user document to a list of UserTiles (excluding the logged-in user)
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Only display users who are not the current logged-in user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container(); // Return empty container if it's the current user
    }
  }
}
