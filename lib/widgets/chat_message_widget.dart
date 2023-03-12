import 'package:flutter/material.dart';

import '../models/models.dart';

class ChatMessageWidget extends StatelessWidget {
  final ConversationMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: message.role == 'user'?
        Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.1)
        : Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.2),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              message.role == 'user'? Icons.account_circle : Icons.smart_toy,
              size: 32
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SelectableText(message.content)
            )
          ],
        )
      ),
    );
  }

}