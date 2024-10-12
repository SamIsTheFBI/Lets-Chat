import 'dart:convert';
import 'package:http/http.dart' as http;

class MatrixRoomService {
  final String homeserverUrl;
  final String accessToken;

  MatrixRoomService(this.homeserverUrl, this.accessToken);

  Future<List<String>> getJoinedRooms() async {
    final url = Uri.parse('$homeserverUrl/_matrix/client/r0/joined_rooms');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return List<String>.from(responseBody['joined_rooms']);
    } else {
      throw Exception('Failed to load joined rooms');
    }
  }
}
