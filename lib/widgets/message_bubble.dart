import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final Function(MessageModel) onReply;
  final bool isCurrentUser;

  const MessageBubble(
      {super.key,
      required this.message,
      required this.onReply,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => onReply(message),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(message.messageBody),
      ),
    );
  }
}
