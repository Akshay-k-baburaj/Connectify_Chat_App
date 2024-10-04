import 'package:chat_service/components/chat_bubble.dart';
import 'package:chat_service/components/my_textfield.dart';
import 'package:chat_service/services/auth/auth_service.dart';
import 'package:chat_service/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
// import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // Import the emoji picker package

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool showEmojiPicker = false; // State to manage emoji picker visibility

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 500,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // Pick and send an image
  void pickAndSendImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String imageUrl = await uploadFileToFirebase(file);
      await _chatService.sendMessage(widget.receiverID, '', fileurl: imageUrl);
    }

    scrollDown();
  }

  // Pick and send a file (general file)
  void pickAndSendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // if (kIsWeb) {
      //   Uint8List? fileBytes = result.files.single.bytes;

      //   if (fileBytes != null) {
      //     String fileURL = await uploadFileBytesToFirebase(
      //         fileBytes, result.files.single.name);
      //     print(
      //         "Sending message with file URL: $fileURL"); // Print statement added here
      //     await _chatService.sendMessage(widget.receiverID, '',
      //         fileUrl: fileURL);
      //   }
      // } else {
      File file = File(result.files.single.path!);
      String fileURL = await uploadFileToFirebase(file);
      print(
          "Sending message with file URL: $fileURL"); // Print statement added here
      await _chatService.sendMessage(widget.receiverID, '', fileurl: fileURL);
    }
    scrollDown();
  }

  // Upload the picked file to Firebase Storage
  Future<String> uploadFileToFirebase(File file) async {
    String fileName = file.path.split('/').last;
    Reference storageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref
        .getDownloadURL(); // Get the URL of the uploaded file
  }

  // Upload the picked bytes to Firebase Storage
  Future<String> uploadFileBytesToFirebase(
      Uint8List fileBytes, String fileName) async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putData(fileBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Send messages
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );
      _messageController.clear();
      setState(() {
        showEmojiPicker = false; // Hide emoji picker after sending message
      });
    }
    scrollDown();
  }

  // Method to handle emoji selection
  void onEmojiSelected(Emoji emoji) {
    _messageController.text += emoji.emoji; // Append selected emoji to message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.grey),
            const SizedBox(width: 10),
            Text(widget.receiverEmail,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (showEmojiPicker) // Show emoji picker if the state is true
            SizedBox(
              height: 250, // Height of the emoji picker
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  onEmojiSelected(emoji);
                },
              ),
            ),
          _buildUserInput(),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    String? fileUrl = data['fileUrl'];
    Timestamp timestamp = data['timestamp'];
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        message: data['message'] ?? '', // Fallback to an empty string
        isCurrentUser: isCurrentUser,
        fileUrl: fileUrl,
        timestamp: timestamp,
      ),
    );
  }

  // Build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: pickAndSendFile,
          ),
          IconButton(
            icon: Icon(Icons.image),
            onPressed: pickAndSendImage,
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions), // Emoji button
            onPressed: () {
              setState(() {
                showEmojiPicker =
                    !showEmojiPicker; // Toggle emoji picker visibility
              });
            },
          ),
          Expanded(
            child: MyTextField(
              hintText: "Type a Message",
              obscureText: false,
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
