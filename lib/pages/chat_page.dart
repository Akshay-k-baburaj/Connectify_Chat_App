import 'package:chat_service/components/chat_bubble.dart';
import 'package:chat_service/components/my_textfield.dart';
import 'package:chat_service/services/auth/auth_service.dart';
import 'package:chat_service/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

  class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat and auth services
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  // for text Field focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState(){
  super.initState();

  // add a listener to focus mode
  myFocusNode.addListener((){
  if(myFocusNode.hasFocus){
  Future.delayed(const Duration(milliseconds: 500),() => scrollDown(),);
  }
  });

  // wait a bit for Listview to be built, then scroll to bottom
  Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }
  @override
  void dispose(){
  myFocusNode.dispose();
  _messageController.dispose();
  super.dispose();
  }
// scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown(){
  _scrollController.animateTo(_scrollController.position.maxScrollExtent,
  duration: const Duration(seconds: 1),
  curve: Curves.fastOutSlowIn,
  );
  }
  // send messages
  void sendMessage() async {
  if(_messageController.text.isNotEmpty){
  await _chatService.sendMessage(widget.receiverID, _messageController.text);

  // clear text controller
  _messageController.clear();
  }
  scrollDown();
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.person, color: Colors.grey), // Person icon
              const SizedBox(width: 10), // Spacing between icon and email
              Text(widget.receiverEmail, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // display all messages
            Expanded(
              child: _buildMessageList(),
            ),
            // user input
            _buildUserInput(),
          ],
        ),
      );
    }

  // build message list
  Widget _buildMessageList(){
  String senderID = _authService.getCurrentUser()!.uid;
  return StreamBuilder(stream: _chatService.getMessages(widget.receiverID, senderID),
  builder: (context, snapshot){
  // errors
  if(snapshot.hasError){
  return const Text("error");
  }
  // loading
  if(snapshot.connectionState == ConnectionState.waiting){
  return const Text("loading....");
  }
  // return list view
  return ListView(
  controller: _scrollController,
  children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
  );
  },
  );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc){
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  // is current user
  bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

  // align message to the right if sender is the current user, otherwise left
  var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
  return Container(
  alignment: alignment,
  child: Column(
  crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  children:[
  ChatBubble(message: data["message"],isCurrentUser: isCurrentUser
  )
  ],
  ));
  }

  // build message input
  Widget _buildUserInput(){
  return Padding(
  padding: const EdgeInsets.only(bottom: 50),
  child: Row(
  children: [
  // text field should take up most of the space
  Expanded(
  child: MyTextField(
  hintText: "Type a Message",
  obscureText: false,
  controller: _messageController,
  focusNode: myFocusNode,
  )),
  // send button
  Container(
  decoration: const BoxDecoration(color: Colors.green,
  shape: BoxShape.circle
  ),
  margin: const EdgeInsets.only(right: 25),
  child: IconButton(
  onPressed: sendMessage,
  icon: const Icon(Icons.arrow_upward, color: Colors.white))),
  ],
  ),
  );
  }
  }
