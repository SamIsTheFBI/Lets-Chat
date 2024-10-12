import 'package:flutter/material.dart';
import '../services/matrix_auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _homeserverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> _signIn() async {
    final homeserverUrl = _homeserverController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (homeserverUrl.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields.";
      });
      return;
    }

    MatrixAuthService authService = MatrixAuthService(homeserverUrl);
    final response = await authService.login(username, password);

    if (response != null && response.containsKey('access_token')) {
      print('Login successful: ${response['access_token']}');
    } else {
      setState(() {
        errorMessage = "Login failed. Please check your credentials.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrix Client - Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _homeserverController,
              decoration: const InputDecoration(labelText: 'Homeserver URL'),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
