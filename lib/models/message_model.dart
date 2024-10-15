class MessageModel {
  final String eventId;
  final String messageBody;
  final String sender;
  final int timestamp;
  final String? replyTo;

  MessageModel({
    required this.eventId,
    required this.messageBody,
    required this.sender,
    required this.timestamp,
    this.replyTo,
  });
}
