import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const MatrixClientApp());
}

class MatrixClientApp extends StatelessWidget {
  const MatrixClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matrix Client App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignInScreen(),
    );
  }
}
