import 'package:flutter/material.dart';
import 'package:matrix_client_app/services/matrix_room_service.dart';
import 'package:matrix_client_app/widgets/room_tile.dart';
import '../models/room_model.dart';

class RoomListScreen extends StatefulWidget {
  final MatrixRoomService matrixRoomService;
  final String query;

  const RoomListScreen(
      {super.key, required this.matrixRoomService, required this.query});

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<RoomModel>? rooms;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchRooms();
  }

  Future<void> _searchRooms() async {
    try {
      List<RoomModel> fetchedRooms =
          await widget.matrixRoomService.searchPublicRooms(widget.query);
      setState(() {
        rooms = fetchedRooms;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms != null && rooms!.isNotEmpty
              ? ListView.builder(
                  itemCount: rooms!.length,
                  itemBuilder: (context, index) {
                    return RoomTile(
                      room: rooms![index],
                      matrixRoomService: widget.matrixRoomService,
                    );
                  },
                )
              : const Center(child: Text('No rooms found')),
    );
  }
}
