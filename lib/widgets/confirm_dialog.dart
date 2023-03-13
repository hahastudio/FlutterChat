import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDialog({
    required this.title,
    required this.content,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}