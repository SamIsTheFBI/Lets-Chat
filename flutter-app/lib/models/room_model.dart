class RoomModel {
  final String roomId;
  final String name;
  final int numJoinedMembers;
  final bool guestCanJoin;

  RoomModel({
    required this.roomId,
    required this.name,
    required this.numJoinedMembers,
    required this.guestCanJoin,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
        roomId: json['room_id'],
        name: json['name'] ?? 'Unnamed Room',
        numJoinedMembers: json['num_joined_members'],
        guestCanJoin: json['guest_can_join']);
  }
}
