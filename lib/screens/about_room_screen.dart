import 'package:flutter/material.dart';
import 'package:matrix_client_app/services/matrix_room_service.dart';

class RoomMembersScreen extends StatefulWidget {
  final String roomId;
  final String accessToken;
  final String homeserverUrl;

  const RoomMembersScreen({
    super.key,
    required this.roomId,
    required this.accessToken,
    required this.homeserverUrl,
  });

  @override
  _RoomMembersScreenState createState() => _RoomMembersScreenState();
}

class _RoomMembersScreenState extends State<RoomMembersScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  late MatrixRoomService roomService;

  @override
  void initState() {
    super.initState();
    roomService = MatrixRoomService(widget.homeserverUrl, widget.accessToken);
    _fetchRoomMembers();
  }

  void _fetchRoomMembers() async {
    try {
      final members = await roomService.getRoomMembers(widget.roomId);
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch room members: $e');
    }

    // print(_members.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Members'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return ListTile(
                  title: Text(member['display_name']),
                  subtitle: Text(member['user_id']),
                );
              },
            ),
    );
  }
}
