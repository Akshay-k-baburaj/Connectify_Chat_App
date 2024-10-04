import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import intl package

import '../themes/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? fileUrl;
  final Timestamp timestamp; // Add this field

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.fileUrl,
    required this.timestamp, // Include this in the constructor
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

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

    // Format the timestamp to only show time
    String formattedTime = DateFormat.jm().format(timestamp.toDate());

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 5, horizontal: 10), // Added horizontal margin for spacing
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // If a file URL is provided, display it
          if (fileUrl != null && fileUrl!.isNotEmpty)
            GestureDetector(
                onTap: () {
                  _openImage(context, fileUrl!);
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 5), // Space between image and message
                  child: ClipRRect(
                    // Rounded corners for the image
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fileUrl!,
                      width: 150, // Adjust width as needed
                      height: 150, // Adjust height as needed
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text("Image failed to load");
                      },
                    ),
                  ),
                )
                // ),
                ),
          // Display the message in the bubble
          if (message.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? (isDarkMode
                        ? Colors.green.shade600
                        : Colors.green.shade500)
                    : (isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.all(16), // Increased padding for the message
              margin: const EdgeInsets.symmetric(
                  horizontal: 25), // Horizontal margin for message
              child: Text(
                message,
                style: TextStyle(
                  color: isCurrentUser
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.black),
                  fontSize: 16, // Increased font size for better readability
                ),
              ),
            ),
          // Display the formatted time with padding
          Padding(
            padding: const EdgeInsets.only(
                top: 5,
                left: 25,
                right: 25), // Added horizontal padding for timestamp
            child: Text(
              formattedTime, // Display only the formatted time
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
