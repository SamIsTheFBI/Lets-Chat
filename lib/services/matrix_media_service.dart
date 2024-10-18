import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MatrixMediaService {
  final String accessToken;
  final String homeserverUrl;

  MatrixMediaService(this.accessToken, this.homeserverUrl);

  // Method to upload media
  Future<String?> uploadMedia(File file) async {
    final uploadUrl =
        '$homeserverUrl/_matrix/media/v3/upload?access_token=$accessToken';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      final contentUri = jsonData[
          'content_uri']; // This is the URI you will use to send the media in the message
      return contentUri;
    } else {
      print('Failed to upload media: ${response.statusCode}');
      return null;
    }
  }

  // Method to send media message in a room
  Future<void> sendMediaMessage(
      String roomId, String mediaUri, String mediaType, String fileName) async {
    final sendMessageUrl =
        '$homeserverUrl/_matrix/client/v3/rooms/$roomId/send/m.room.message?access_token=$accessToken';

    final body = jsonEncode({
      'msgtype': mediaType, // Can be m.image, m.video, m.file, etc.
      'body': fileName, // File name or a description
      'url': mediaUri, // Matrix content URI for the uploaded file
    });

    final response = await http.post(
      Uri.parse(sendMessageUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Media message sent successfully.');
    } else {
      print('Failed to send media message: ${response.statusCode}');
    }
  }
}
