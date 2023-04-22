import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/models.dart';

class ChatMessageWidget extends StatefulWidget {
  final ConversationMessage message;
  final bool isMarkdown;

  const ChatMessageWidget({super.key, required this.message, this.isMarkdown = true});

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  bool _showContextMenu = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: widget.message.role == 'user' ?
        Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.1)
        : Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showContextMenu = !_showContextMenu;
              });
            },
            child: SizedBox(
              width: 32,
              child: Column(
                children: [
                  Icon(
                    widget.message.role == 'user'? Icons.account_circle : Icons.smart_toy,
                    size: 32
                  ),
                  if (_showContextMenu) const SizedBox(height: 16),
                  if (_showContextMenu) IconButton(
                    icon: const Icon(Icons.content_copy, size: 20),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: widget.message.content));
                    }
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: widget.isMarkdown ?
              MarkdownBody(data: widget.message.content, selectable: true)
              : SelectableText(widget.message.content)
          )
        ],
      )
    );
  }

}