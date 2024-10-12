import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/matrix_message_service.dart';
import '../services/matrix_room_service.dart'; // Import room service

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String homeserverUrl;
  final String accessToken;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.homeserverUrl,
    required this.accessToken,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late MatrixMessageService messageService;
  late MatrixRoomService roomService;
  late Future<List<Map<String, dynamic>>> roomMessages;
  late Future<Map<String, dynamic>> roomDetails;
  List<Map<String, dynamic>> messages = [];
  String roomName = 'Loading...'; // Initial value
  String? roomAvatar; // Null if not available

  @override
  void initState() {
    super.initState();
    messageService =
        MatrixMessageService(widget.homeserverUrl, widget.accessToken);
    roomService = MatrixRoomService(widget.homeserverUrl, widget.accessToken);
    _loadMessages();
    _fetchRoomDetails();
  }

  // Load room messages
  void _loadMessages() async {
    roomMessages = messageService.getRoomMessages(widget.roomId);
    roomMessages.then((loadedMessages) {
      setState(() {
        messages = loadedMessages;
      });
    }).catchError((error) {
      print('Error loading messages: $error');
    });
  }

  // Fetch room details
  void _fetchRoomDetails() async {
    try {
      final details = await roomService.getRoomDetails(widget.roomId);
      setState(() {
        roomName = details['name'];
        roomAvatar = details['avatar']; // Avatar may be null
      });
    } catch (error) {
      print('Error loading room details: $error');
    }
  }

  // Send a message to the room
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      await messageService.sendMessage(widget.roomId, messageText);
      _messageController.clear();
      _loadMessages(); // Reload messages after sending a new one
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Room Avatar
            roomAvatar != null
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage('${widget.homeserverUrl}$roomAvatar'),
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.grey, // Default grey circle
                    child: Icon(Icons.person),
                  ),
            const SizedBox(width: 10), // Space between avatar and name
            // Room Name
            Text(roomName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: roomMessages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages found'));
                } else {
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final messageBody =
                          message['content']?['body'] ?? 'Unknown Message';
                      final messageSender =
                          message['sender'] ?? 'Unknown Sender';

                      return ListTile(
                        title: Text(messageBody), // Ensure this won't be null
                        subtitle:
                            Text(messageSender), // Ensure this won't be null
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
