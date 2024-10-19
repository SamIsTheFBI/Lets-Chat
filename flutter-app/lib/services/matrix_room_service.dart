import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matrix_client_app/models/room_model.dart';

class MatrixRoomService {
  final String homeserverUrl;
  final String accessToken;

  MatrixRoomService(this.homeserverUrl, this.accessToken);

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId) async {
    final url =
        '$homeserverUrl/_matrix/client/v3/rooms/$roomId/members?access_token=$accessToken';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // print("pahuncha");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('joined members $data');
      List<Map<String, dynamic>> members = [];
      if (data['chunk'] != null) {
        for (var member in data['chunk']) {
          members.add({
            'user_id': member['state_key'],
            'display_name':
                member['content']['displayname'] ?? member['state_key'],
          });
        }
      }
      return members;
    } else {
      throw Exception('Failed to load room members');
    }
  }

  Future<bool> isRoomEncrypted(String roomId) async {
    final url =
        '$homeserverUrl/_matrix/client/v3/rooms/$roomId/state/m.room.encryption?access_token=$accessToken';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true; // The room is encrypted
    } else if (response.statusCode == 404) {
      return false; // The room is not encrypted
    } else {
      throw Exception('Failed to fetch encryption status');
    }
  }

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
        'avatar': avatarBody?['url']
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

  Future<List<RoomModel>> searchPublicRooms(String query) async {
    final url = Uri.parse(
        '$homeserverUrl/_matrix/client/r0/publicRooms?limit=10&filter={"generic_search_term":"$query"}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List rooms = data['chunk'];
      return rooms.map((room) => RoomModel.fromJson(room)).toList();
    } else {
      throw Exception('Failed to search rooms: ${response.statusCode}');
    }
  }

  // Join a room by roomId
  Future<void> joinRoom(String roomId) async {
    final url = Uri.parse('$homeserverUrl/_matrix/client/r0/join/$roomId');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to join room: ${response.statusCode}');
    }
  }

  Future<void> leaveRoom(String roomId) async {
    final url =
        '$homeserverUrl/_matrix/client/v3/rooms/$roomId/leave?access_token=$accessToken';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Left the room successfully.');
    } else {
      print('Failed to leave the room: ${response.statusCode}');
    }
  }
}
