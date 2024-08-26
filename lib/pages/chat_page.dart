import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test/components/my_textfield.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/chat/chat_service.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth servcies
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (receiverID == "000" || receiverEmail == "xxx") {
      return Scaffold(
          appBar: AppBar(title: Text(receiverEmail)),
          body: Text("Failed to create chatroom!"));
    }
    return Scaffold(
      appBar: AppBar(title: Text(receiverEmail)),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
    // TODO: implement build
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: data["senderID"] + ": ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          TextSpan(
            text: data["message"],
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
    // return Text((data["senderID"]) + ": " + data["message"]);
  }

  // Build message input

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
              hintText: "Type a message",
              obscureText: false,
              controller: _messageController),
        ),
        // send button
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))
      ],
    );
  }
}
