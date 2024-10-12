import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/matrix_room_service.dart';
import 'sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  final String homeserverUrl;
  final String accessToken;

  const HomeScreen(
      {super.key, required this.homeserverUrl, required this.accessToken});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MatrixRoomService roomService;
  late Future<List<String>> joinedRooms;

  @override
  void initState() {
    super.initState();
    roomService = MatrixRoomService(widget.homeserverUrl, widget.accessToken);
    joinedRooms = roomService.getJoinedRooms();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Client - Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: joinedRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading rooms'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No joined rooms found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Room ID: ${snapshot.data![index]}'),
                  onTap: () {
                    // Navigate to the chat screen
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
