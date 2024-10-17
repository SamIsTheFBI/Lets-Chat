import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix_client_app/screens/home_screen.dart';
import 'package:matrix_client_app/screens/sign_in_screen.dart';
import 'package:matrix_client_app/screens/splash_screen.dart';
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
  final Widget _initialScreen = const CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    // _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ciphera App',
      theme: lightMode,
      home: const SplashScreen(),
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
