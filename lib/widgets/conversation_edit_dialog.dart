import 'package:flutter/material.dart';

import '../models/models.dart';

class ConversationEditDialog extends StatefulWidget {
  final Conversation conversation;
  final bool isEdit;

  const ConversationEditDialog({
    required this.conversation,
    this.isEdit = false,
    super.key
  });

  @override
  State<ConversationEditDialog> createState() => _ConversationEditDialogState();
}

class _ConversationEditDialogState extends State<ConversationEditDialog> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleEditingController;
  late TextEditingController _systemMessageEditingController;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _titleEditingController = TextEditingController();
    _systemMessageEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _systemMessageEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = widget.conversation.title;
    _systemMessageEditingController.text = widget.conversation.systemMessage;

    return AlertDialog(
      content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleEditingController,
                validator: (value) {
                  return value != null && value.isEmpty ? 'Title should not be empty' : null;
                },
                decoration: const InputDecoration(hintText: 'Enter a conversation title'),
              ),
              TextFormField(
                controller: _systemMessageEditingController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Message to help set the behavior of the assistant'),
              ),
            ],
          )
      ),
      title: Text(widget.isEdit? 'Edit conversation' : 'New conversation'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            if (_formKey.currentState == null || !_formKey.currentState!.validate())
              return;
            widget.conversation.title = _titleEditingController.text;
            widget.conversation.systemMessage = _systemMessageEditingController.text;
            if (!widget.isEdit)
              widget.conversation.lastUpdated = DateTime.now();
            Navigator.of(context).pop(widget.conversation);
          },
        ),
      ],
    );
  }

}