import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? fileUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Function to open the image
    void _openImage(BuildContext context, String imageUrl) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            body: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // If a file URL is provided, display it
          if (fileUrl != null && fileUrl!.isNotEmpty) // Check for null before accessing isNotEmpty
            GestureDetector(
              onTap: () {
                _openImage(context, fileUrl!); // Make sure this method is defined
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 5), // Space between file and message
                child: Image.network(
                  fileUrl!,
                  width: 100, // Adjust width as needed
                  height: 100, // Adjust height as needed
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("Image failed to load");
                  },
                ),
              ),
            ),
          // Display the message in the bubble
          if (message.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500)
                    : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                message,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}