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

  String getEventDisplayText(Map<String, dynamic> event) {
    // Handling different event types
    switch (event['type']) {
      case 'm.room.message':
        // Check if it's a normal text message
        if (event['content']['msgtype'] == 'm.text') {
          return event['content']['body'];
        } else {
          return '[Unsupported message type]';
        }

      case 'm.room.member':
        // Event for when users join/leave rooms
        final membership = event['content']['membership'];
        if (membership == 'join') {
          return '${event['sender']} joined the room';
        } else if (membership == 'leave') {
          return '${event['sender']} left the room';
        } else if (membership == 'invite') {
          return '${event['sender']} invited someone to the room';
        }
        return '[Unknown membership event]';

      case 'm.room.create':
        // Room creation event
        return 'Room was created by ${event['sender']}';

      case 'm.room.encryption':
        // Encryption enabled
        return 'End-to-end encryption enabled for this room';

      case 'm.room.name':
        // Room name changed
        return 'Room name changed to "${event['content']['name']}" by ${event['sender']}';

      case 'm.room.avatar':
        // Room avatar changed
        return 'Room avatar updated by ${event['sender']}';

      case 'm.room.join_rules':
        // Join rules updated
        final joinRule = event['content']['join_rule'];
        return 'Join rules changed to "$joinRule" by ${event['sender']}';

      case 'm.room.history_visibility':
        // History visibility updated
        final visibility = event['content']['history_visibility'];
        return 'History visibility changed to "$visibility" by ${event['sender']}';

      case 'm.room.power_levels':
        // Power levels updated
        return 'Power levels updated by ${event['sender']}';
      case "m.room.guest_access":
        final guestAccess = event['content']['guest_access'];
        if (guestAccess == 'can_join') {
          return '${event['sender']} has allowed guests to join the room.';
        } else {
          return '${event['sender']} has forbidden guests to join the room.';
        }

      default:
        return event.toString();
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

                      final messageBody = getEventDisplayText(message);
                      final messageSender =
                          message['sender'] ?? 'Unknown Sender';

                      if (message['type'] == 'm.room.message') {
                        return ListTile(
                          title: Text(
                            messageBody,
                            style: TextStyle(
                              fontSize:
                                  message['type'] != 'm.room.message' ? 10 : 18,
                            ),
                          ), // Ensure this won't be null
                          subtitle: Text(
                            messageSender,
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ), // Ensure this won't be null
                        );
                      } else {
                        return ListTile(
                          visualDensity: const VisualDensity(
                              horizontal: 0, vertical: -4.0),
                          title: Text(
                            messageBody,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
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
