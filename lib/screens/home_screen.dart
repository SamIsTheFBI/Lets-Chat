import 'package:flutter/material.dart';
import 'package:matrix_client_app/screens/room_creation_screen.dart';
import 'package:matrix_client_app/screens/welcome_screen.dart';
import 'package:matrix_client_app/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/matrix_room_service.dart';
import 'sign_in_screen.dart';
import 'chat_screen.dart';
import 'room_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final String homeserverUrl;
  final String accessToken;

  const HomeScreen(
      {super.key, required this.homeserverUrl, required this.accessToken});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class RoomSearchDelegate extends SearchDelegate {
  final MatrixRoomService matrixRoomService;

  RoomSearchDelegate({required this.matrixRoomService});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return RoomListScreen(matrixRoomService: matrixRoomService, query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
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
    final roomSearchController = TextEditingController();

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
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  Future<void> _navigateToRoomCreation() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RoomCreationScreen(
                accessToken: widget.accessToken,
                homeserverUrl: widget.homeserverUrl)));
    if (result == true) {
      _refreshRoomList();
    }
  }

  Future<void> _navigateToRoomSearch() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RoomListScreen(matrixRoomService: roomService, query: '')));
    if (result == true) {
      _refreshRoomList();
    }
  }

  @override
  Widget build(BuildContext context) {
    _refreshRoomList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: RoomSearchDelegate(matrixRoomService: roomService),
              );
              _refreshRoomList();
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRoomList,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToRoomCreation,
        tooltip: 'Create Room',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      drawer: const HomeDrawer(),
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
                          ).then((_) {
                            _refreshRoomList();
                          });
                          _refreshRoomList();
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
