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
      title: 'Ciphera App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignInScreen(),
    );
  }
}
