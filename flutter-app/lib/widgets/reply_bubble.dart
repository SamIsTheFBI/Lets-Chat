import 'package:flutter/material.dart';

class ReplyBubble extends StatelessWidget {
  final String replyTo;

  const ReplyBubble({super.key, required this.replyTo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        'Replying to: ${replyTo.substring(0, 50)}...',
        style:
            TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade800),
      ),
    );
  }
}
