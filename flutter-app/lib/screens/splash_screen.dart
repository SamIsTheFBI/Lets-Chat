import 'package:flutter/material.dart';
import 'package:matrix_client_app/screens/home_screen.dart';
import 'package:matrix_client_app/screens/welcome_screen.dart';
import 'package:matrix_client_app/services/matrix_auth_service.dart';
import 'package:matrix_client_app/utils/storage_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if the user is authenticated with a stored access token and homeserver
    String? homeserverUrl = await StorageUtil.getHomeserver();
    if (homeserverUrl is String) {
      final MatrixAuthService authService = MatrixAuthService(homeserverUrl);
      // String? accessToken = await StorageUtil.getAccessToken();
      bool isAuthenticated = await authService.isAuthenticated();
      String access = StorageUtil.getAccessToken().toString();
      final String homeserver = StorageUtil.getHomeserver().toString();
      if (isAuthenticated) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => HomeScreen(
                    homeserverUrl: homeserver, accessToken: access)));
      }
    } else {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
