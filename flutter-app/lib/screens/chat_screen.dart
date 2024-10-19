import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix_client_app/models/message_model.dart';
import 'package:matrix_client_app/screens/about_room_screen.dart';
import 'package:matrix_client_app/screens/sign_in_screen.dart';
import 'package:matrix_client_app/screens/voice_chat_screen.dart';
import 'package:matrix_client_app/services/matrix_media_service.dart';
import 'package:file_picker/file_picker.dart';
import '../services/matrix_message_service.dart';
import '../services/matrix_room_service.dart';
import 'dart:async';

Timer? timer;

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
  late MatrixMediaService mediaService;
  late MatrixRoomService roomService;
  late Future<List<Map<String, dynamic>>> roomMessages;
  late Future<Map<String, dynamic>> roomDetails;
  List<Map<String, dynamic>> messages = [];
  String roomName = 'Loading...'; // Initial value
  String? roomAvatar; // Null if not available
  String memberCount = 'Loading member count...';
  MessageModel? _messageToReply;
  String currentUser = '';
  String roomCreator = '';
  bool isRoomOwner = false;
  String roomId = '';
  bool isRoomEncrypted = false;

  @override
  void initState() {
    super.initState();
    messageService =
        MatrixMessageService(widget.homeserverUrl, widget.accessToken);
    roomService = MatrixRoomService(widget.homeserverUrl, widget.accessToken);
    mediaService = MatrixMediaService(widget.accessToken, widget.homeserverUrl);
    _loadMessages();
    _getCurrentUser();
    _fetchRoomDetails();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => checkMess);
  }

  void checkMess() {
    final tempRoomMessages = messageService.getRoomMessages(widget.roomId);
    int len = 0;
    tempRoomMessages.then((loadedMess) {
      len = loadedMess.length;
    });

    print(len);
    if (len != messages.length) {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _getCurrentUser() async {
    final res = await messageService.getCurrentUser();
    if (res is String) {
      currentUser = res;
    }
  }

  // Load room messages
  void _loadMessages() async {
    roomMessages = messageService.getRoomMessages(widget.roomId);
    roomMessages.then((loadedMessages) {
      setState(() {
        messages = loadedMessages;
      });

      for (final message in messages) {
        if (message['type'] == 'm.room.encryption') {
          isRoomEncrypted = true;
        }
      }
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
        roomAvatar = details['avatar'];
      });
    } catch (error) {
      print('Error loading room details: $error');
    }
  }

  // Send a message to the room
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      print(isRoomEncrypted);
      if (isRoomEncrypted) {}
      await messageService.sendMessage(widget.roomId, messageText,
          replyTo: _messageToReply?.messageBody);
      _messageController.clear();
      _messageToReply = null;
      _loadMessages(); // Reload messages after sending a new one
    }
  }

  void _handleReply(MessageModel message) {
    setState(() {
      _messageToReply = message;
    });
  }

  String getEventDisplayText(Map<String, dynamic> event) {
    // Handling different event types
    switch (event['type']) {
      case 'm.room.message':
        // Check if it's a normal text message
        if (event['content']['msgtype'] == 'm.text') {
          return event['content']['body'];
        } else {
          return event.toString();
          // return '[Unsupported message type]';
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
        isRoomEncrypted = true;
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
      // return '[unknown event]';
    }
  }

  Widget _buildImageMessage(Map<String, dynamic> message, bool isCurrentUser) {
    // final thumbnailUrl = message['content']['info']['thumbnail_url'];
    String fileUrl = message['content']['url'];
    final urlWithoutMxc = fileUrl.substring(6 + 10);

    // final imageUrl =
    //     '${widget.homeserverUrl}/_matrix/client/v1/media/download/127.0.0.1/YGoWJrHpbPWWpTFZVnrRuwRr?access_token=${widget.accessToken}';
    final imageUrl =
        '${widget.homeserverUrl}/_matrix/client/v1/media/download/localhost/$urlWithoutMxc?access_token=${widget.accessToken}';

    // print(imageUrl);
    return SelectableText(
      imageUrl,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            urlWithoutMxc,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Image.network(
            imageUrl,
            height: 360,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageModel message, bool isCurrentUser) {
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: !isCurrentUser,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                message.sender,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: isCurrentUser
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
              color: isRoomEncrypted
                  ? Colors.green
                  : isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
            ),
            child: Text(
              message.messageBody,
              style: TextStyle(
                color: isRoomEncrypted
                    ? Colors.white
                    : isCurrentUser
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSendMedia() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      // Upload the media file
      String? mediaUri = await mediaService.uploadMedia(file);
      if (mediaUri != null) {
        // Send media message
        String mediaType = _getMediaType(file);
        await mediaService.sendMediaMessage(
            widget.roomId, mediaUri, mediaType, result.files.single.name);
        print('sent media message');
        _loadMessages();
      }
    } else {
      print('File selection canceled.');
    }
  }

  String _getMediaType(File file) {
    // Determine media type based on file extension
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'm.image';
      case 'mp4':
      case 'mov':
        return 'm.video';
      default:
        return 'm.file';
    }
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        // Container(
        //   margin: const EdgeInsets.only(right: 7),
        //   child: IconButton(
        //     icon: Icon(
        //       Icons.attach_file,
        //       color: Theme.of(context).colorScheme.onSurface,
        //     ),
        //     onPressed: () {},
        //     // onPressed: _pickAndSendMedia,
        //     color: Theme.of(context).colorScheme.inversePrimary,
        //   ),
        // ),
        Expanded(
          child: TextField(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            controller: _messageController,
            decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                hintText: 'Enter your message',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                )),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.only(right: 7, left: 13),
          child: IconButton(
            icon: const Icon(Icons.north_east),
            onPressed: _sendMessage,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ],
    );
  }

  void _showInviteLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite Link copied to clipboard!')),
    );
  }

  void _leaveRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Room'),
          content: const Text('Are you sure you want to leave this room?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Perform leave room logic
                await roomService.leaveRoom(roomId);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit to previous screen
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Room'),
          content: const Text(
              'Are you sure you want to delete this room? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform delete room logic
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit to previous screen
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Ensures space between room name and button
            children: [
              // Room Name
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roomName),
                  ],
                ),
              ),

              // Call button aligned to the right
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VoiceChatScreen()),
                  );
                },
                child: Icon(
                  Icons.call,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle the menu actions
                if (value == 'Invite Link') {
                  _showInviteLink(context);
                } else if (value == 'Leave Room') {
                  _leaveRoom(context);
                } else if (value == 'Delete Room') {
                  _deleteRoom(context);
                } else if (value == 'About Room') {
                  // page for about room
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RoomMembersScreen(
                        roomId: roomId,
                        accessToken: widget.accessToken,
                        homeserverUrl: widget.homeserverUrl,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'About Room',
                  child: Text('About Room'),
                ),
                const PopupMenuItem<String>(
                  value: 'Invite Link',
                  child: Text('Invite Link'),
                ),
                const PopupMenuItem<String>(
                  value: 'Leave Room',
                  child: Text('Leave Room'),
                ),
                if (roomCreator ==
                    currentUser) // Show "Delete Room" only if the user is the owner
                  const PopupMenuItem<String>(
                    value: 'Delete Room',
                    child: Text('Delete Room'),
                  ),
              ],
            ),
          ],
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

                        bool isCurrentUser = messageSender == currentUser;
                        roomId = message['room_id'];

                        // if (message['content']['msgtype'] == 'm.image') {
                        //   return _buildImageMessage(message, isCurrentUser);
                        // } else
                        if (message['type'] == 'm.room.message') {
                          final MessageModel modelMessage = MessageModel(
                              eventId: message['event_id'],
                              messageBody: messageBody,
                              sender: messageSender,
                              timestamp: message['origin_server_ts']);

                          return _buildMessageItem(modelMessage, isCurrentUser);
                        } else {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                messageBody,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
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

            // user input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildUserInput(),
            ),
          ],
        ),
      ),
    );
  }
}
