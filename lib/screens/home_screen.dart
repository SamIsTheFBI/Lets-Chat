import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/matrix_room_service.dart';
import 'sign_in_screen.dart';
import 'chat_screen.dart';

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
  late Future<List<Map<String, String>>> joinedRooms;

  @override
  void initState() {
    super.initState();
    roomService = MatrixRoomService(widget.homeserverUrl, widget.accessToken);
    _refreshRoomList();
  }

  // Fetch and refresh the room list
  void _refreshRoomList() {
    setState(() {
      joinedRooms = roomService.getJoinedRooms();
    });
  }

  // Create a new room
  Future<void> _createRoom() async {
    final roomNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Room'),
        content: TextField(
          controller: roomNameController,
          decoration: const InputDecoration(hintText: 'Room name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final roomName = roomNameController.text;
              if (roomName.isNotEmpty) {
                await roomService.createRoom(roomName);
                _refreshRoomList(); // Refresh room list after creating a new room
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
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
        title: const Text('Ciphera - Rooms'),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.search)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        tooltip: 'Create Room',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
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
                      final room = snapshot.data![index];
                      return ListTile(
                        title: Text(room['name'] ?? 'Unnamed Room'),
                        onTap: () {
                          // Navigate to the chat screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                roomId: room['id']!,
                                homeserverUrl: widget.homeserverUrl,
                                accessToken: widget.accessToken,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
