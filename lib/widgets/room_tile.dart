import 'package:flutter/material.dart';
import 'package:matrix_client_app/services/matrix_room_service.dart';
import '../models/room_model.dart';

class RoomTile extends StatelessWidget {
  final RoomModel room;
  final MatrixRoomService matrixRoomService;

  const RoomTile({
    super.key,
    required this.room,
    required this.matrixRoomService,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(room.name),
      subtitle: Row(
        children: [
          const Icon(Icons.person),
          const SizedBox(
            width: 10,
          ),
          Text(room.numJoinedMembers.toString()),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () async {
          try {
            await matrixRoomService.joinRoom(room.roomId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Joined ${room.name} successfully!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to join: $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, foregroundColor: Colors.white),
        child: const Text('Join'),
      ),
    );
  }
}
