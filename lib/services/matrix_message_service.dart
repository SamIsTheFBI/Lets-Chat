import 'dart:convert';
import 'package:http/http.dart' as http;

class MatrixMessageService {
  final String homeserverUrl;
  final String accessToken;

  MatrixMessageService(this.homeserverUrl, this.accessToken);

  Future<List<Map<String, dynamic>>> getRoomMessages(String roomId) async {
    final url = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/rooms/$roomId/messages?dir=b&limit=20');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final chunk = List<Map<String, dynamic>>.from(responseBody['chunk']);
      return chunk;
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Fetch recent messages from the room
  Future<List<Map<String, dynamic>>> getMessages(String roomId) async {
    final url = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/rooms/$roomId/messages?limit=20&dir=b');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseBody['chunk']);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<String?> getCurrentUser() async {
    final url = Uri.parse('$homeserverUrl/_matrix/client/r0/account/whoami');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user_id']; // This is the Matrix ID of the user
    } else {
      print('Failed to get current user: ${response.statusCode}');
      return null;
    }
  }

  // Send a new message to the room
  Future<void> sendMessage(String roomId, String message,
      {String? replyTo}) async {
    final txnId = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Unique transaction ID
    final url = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/rooms/$roomId/send/m.room.message/$txnId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'msgtype': 'm.text',
        'body': message,
        if (replyTo != null)
          "m.relates_to": {
            "m.in_reply_to": {"event_id": replyTo}
          }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}
