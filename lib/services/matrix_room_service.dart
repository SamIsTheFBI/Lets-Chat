import 'dart:convert';
import 'package:http/http.dart' as http;

class MatrixRoomService {
  final String homeserverUrl;
  final String accessToken;

  MatrixRoomService(this.homeserverUrl, this.accessToken);

  Future<Map<String, dynamic>> getRoomDetails(String roomId) async {
    final url = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/rooms/$roomId/state/m.room.name');
    final avatarUrl = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/rooms/$roomId/state/m.room.avatar');

    // Fetch room name
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    // Fetch avatar (if available)
    final avatarResponse = await http.get(avatarUrl, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final avatarBody = avatarResponse.statusCode == 200
          ? jsonDecode(avatarResponse.body)
          : null;

      return {
        'name': responseBody['name'] ?? 'Unnamed Room',
        'avatar': avatarBody?['url'], // Avatar might not exist
      };
    } else {
      throw Exception('Failed to fetch room details');
    }
  }

  Future<List<Map<String, String>>> getJoinedRooms() async {
    final url = Uri.parse('$homeserverUrl/_matrix/client/r0/joined_rooms');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final roomIds = List<String>.from(responseBody['joined_rooms']);

      // Fetch room details to get room names
      List<Map<String, String>> rooms = [];
      for (String roomId in roomIds) {
        final roomName = await getRoomName(roomId);
        rooms.add({'id': roomId, 'name': roomName});
      }

      return rooms;
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  // Fetch room name from room ID
  Future<String> getRoomName(String roomId) async {
    final url = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/rooms/$roomId/state/m.room.name');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['name'] ??
          'Unnamed Room'; // Default if no name is set
    } else {
      return 'Unnamed Room';
    }
  }

  // Create a new room
  Future<void> createRoom(String roomName) async {
    final url = Uri.parse('$homeserverUrl/_matrix/client/r0/createRoom');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': roomName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create room');
    }
  }
}
