import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_service/pages/chat_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchResultEmail = '';
  String _searchResultUID = '';
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search user by email
  void searchUserByEmail() async {
    String email = _searchController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an email address';
        _searchResultEmail = '';
        _searchResultUID = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // If user is found, set email and UID
        setState(() {
          _searchResultEmail = snapshot.docs.first.get('email');
          _searchResultUID = snapshot.docs.first.get('uid');
          _isLoading = false;
        });
      } else {
        // If no user is found, show a message
        setState(() {
          _searchResultEmail = 'No user found with this email';
          _searchResultUID = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle errors during Firestore query
      setState(() {
        _errorMessage = 'Error fetching user data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text field for searching users by email
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter email to search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchUserByEmail, // Trigger search function
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display error messages
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            // Show loading indicator while searching
            if (_isLoading) const CircularProgressIndicator(),

            // Display search result and navigate to ChatPage if a user is found
            if (_searchResultEmail.isNotEmpty && _searchResultUID.isNotEmpty)
              ListTile(
                title: Text(_searchResultEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    // Navigate to ChatPage with the selected user's email and UID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverEmail: _searchResultEmail,
                          receiverID: _searchResultUID,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // If no user is found, display a message
            if (_searchResultEmail == 'No user found with this email')
              Text(_searchResultEmail),
          ],
        ),
      ),
    );
  }
}
