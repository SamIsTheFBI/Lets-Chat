import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomCreationScreen extends StatefulWidget {
  final String accessToken;
  final String homeserverUrl;

  const RoomCreationScreen(
      {super.key, required this.accessToken, required this.homeserverUrl});

  @override
  _RoomCreationScreenState createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  bool _isEncrypted = false;
  String _visibility = 'private'; // Default visibility is private

  Future<void> createRoom() async {
    Map<String, dynamic> roomCreationPayload = {
      'name': _roomNameController.text,
      'visibility': _visibility,
      if (_isEncrypted)
        'initial_state': [
          {
            'type': 'm.room.encryption',
            'state_key': '',
            'content': {
              'algorithm': 'm.megolm.v1.aes-sha2',
            },
          },
        ],
    };

    final response = await http.post(
      Uri.parse('${widget.homeserverUrl}/_matrix/client/r0/createRoom'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(roomCreationPayload),
    );

    print(widget.accessToken);
    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Go back to the room list after creation
    } else {
      throw Exception('Failed to create room');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            const SizedBox(height: 20),

            // Dropdown for Room Visibility
            DropdownButtonFormField<String>(
              value: _visibility,
              decoration: const InputDecoration(labelText: 'Room Visibility'),
              items: const [
                DropdownMenuItem(
                  value: 'private',
                  child: Text('Private'),
                ),
                DropdownMenuItem(
                  value: 'public',
                  child: Text('Public'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _visibility = newValue!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Switch for Encryption
            SwitchListTile(
              title: const Text('Enable End-to-End Encryption'),
              value: _isEncrypted,
              onChanged: (bool value) {
                setState(() {
                  _isEncrypted = value;
                });
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createRoom,
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}
