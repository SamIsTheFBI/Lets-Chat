import 'dart:convert';
import 'package:http/http.dart' as http;

class MatrixAuthService {
  final String homeserverUrl;

  MatrixAuthService(this.homeserverUrl);

  Future<Map<String, dynamic>?> login(String username, String password) async {
    String stringUrl = '$homeserverUrl/_matrix/client/r0/login';
    final url = Uri.parse(stringUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': 'm.login.password',
        'user': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
