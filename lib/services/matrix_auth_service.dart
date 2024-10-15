import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matrix_client_app/main.dart';
import 'package:matrix_client_app/utils/storage_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatrixAuthService {
  final String homeserverUrl;

  MatrixAuthService({this.homeserverUrl = 'http://10.0.2.2:8008'});

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
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      await StorageUtil.saveAccessToken(accessToken);
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    String? accessToken = await StorageUtil.getAccessToken();
    String? homeserverUrl = await StorageUtil.getHomeserver();
    if (accessToken == null || homeserverUrl == null) {
      return false;
    }

    final url = Uri.parse('$homeserverUrl/_matrix/client/r0/account/whoami');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    print(response.statusCode == 200);
    return response.statusCode == 200;
  }

  Future<void> logOut() async {
    await StorageUtil.removeAccessToken();
  }
}
