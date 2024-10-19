import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class MatrixMediaService {
  final String accessToken;
  final String homeserverUrl;

  MatrixMediaService(this.accessToken, this.homeserverUrl);

  Future<String?> uploadMedia(File file) async {
    final uploadUrl =
        '$homeserverUrl/_matrix/media/v3/upload?filename=justAFile&access_token=$accessToken';

    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: 'file'),
    });

    final response = await Dio().post(
      uploadUrl,
      data: formData,
    );

    // final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    // print('file path: ${file.path}');
    // request.files.add(http.MultipartFile(
    //   'file',
    //   file.readAsBytes().asStream(),
    //   file.lengthSync(),
    //   contentType: MediaType('image', 'jpeg'),
    // ));

    // final response = await request.send();

    if (response.statusCode == 200) {
      // final responseBody = await response.stream.bytesToString();
      // final jsonData = jsonDecode(responseBody);
      final jsonData = response.data;
      print(jsonData);
      final contentUri = jsonData['content_uri'];
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

    Map<String, dynamic> content = {
      'msgtype': mediaType,
      'body': fileName,
      'url': mediaUri,
    };

    if (mediaType == 'm.image') {
      content['info'] = {
        'mimetype': 'image/jpeg',
        'thumbnail_url': mediaUri,
        'w': 300,
        'h': 300,
      };
    }

    final body = jsonEncode(content);

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
