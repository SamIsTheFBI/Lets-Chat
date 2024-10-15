import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix_client_app/screens/home_screen.dart';
import 'package:matrix_client_app/screens/sign_in_screen.dart';
import 'package:matrix_client_app/services/matrix_auth_service.dart';
import 'package:matrix_client_app/themes/light_mode.dart';
import 'package:matrix_client_app/utils/storage_util.dart';
import 'screens/welcome_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MatrixAuthService _authService = MatrixAuthService();
  Widget _initialScreen = const CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if the user is authenticated with a stored access token and homeserver
    bool isAuthenticated = await _authService.isAuthenticated();
    String? homeserverUrl = await StorageUtil.getHomeserver();
    String? accessToken = await StorageUtil.getAccessToken();

    setState(() {
      if (isAuthenticated && homeserverUrl is String && accessToken is String) {
        _initialScreen =
            HomeScreen(homeserverUrl: homeserverUrl, accessToken: accessToken);
      } else {
        _initialScreen = const WelcomeScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ciphera App',
      theme: lightMode,
      home: Scaffold(
        body: Center(
          child: _initialScreen,
        ),
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
}

// 
// void main() {
//   runApp(const MatrixClientApp());
// }

// class MatrixClientApp extends StatelessWidget {
//   const MatrixClientApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return 
//   }
// }
