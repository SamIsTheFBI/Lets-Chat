import 'package:flutter/material.dart';
import 'package:matrix_client_app/screens/splash_screen.dart';
import 'package:matrix_client_app/themes/light_mode.dart';
import 'package:matrix_client_app/themes/theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      theme: Provider.of<ThemeProvider>(context).themeData,
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
