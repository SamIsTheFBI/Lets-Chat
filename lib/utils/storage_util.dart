import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static const String _accessTokenKey = 'access_token';
  static const String _homeServer = 'http://10.0.2.2:8008';

  // Save access token
  static Future<void> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Remove access token (on logout)
  static Future<void> removeAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  static Future<String?> getHomeserver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_homeServer);
  }

  static Future<void> saveHomeserver(String homeserver) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeServer, homeserver);
  }
}
