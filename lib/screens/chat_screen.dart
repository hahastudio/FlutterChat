import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../widgets/widgets.dart';

class ChatScreenPage extends StatelessWidget {
  const ChatScreenPage({super.key});

  static Route<void> route(Conversation initialConversation) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => ChatBloc(
          chatService: context.read<ChatService>(),
          initialConversation: initialConversation,
        ),
        child: const ChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
        previous.status != current.status &&
          current.status == ChatStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  late ScrollController _scrollController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  bool _showSystemMessage = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    var conversation = state.initialConversation;

    if (state.status == ChatStatus.failure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conversation.error),
            action: SnackBarAction(
              label: 'Resend',
              onPressed: () {
                BlocProvider.of<ChatBloc>(context).add(
                    ChatSubmitted(conversation)
                );
              },
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(conversation.title, style: const TextStyle(overflow: TextOverflow.ellipsis)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              setState(() {
                _showSystemMessage = !_showSystemMessage;
              });
            },
          )
        ]
      ),
      body: SafeArea(
        child: Column(
          children: [
            // system message
            if(_showSystemMessage)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(conversation.systemMessage)
                  )
                ],
              )
            ),
            // chat messages
            Flexible(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: conversation.messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(message: conversation.messages[index]);
                },
              )
            ),
            // loading indicator
            if (state.status == ChatStatus.loading)
              const SizedBox(height: 8),
            if (state.status == ChatStatus.loading)
              const SpinKitThreeBounce(color: Colors.green, size: 18),
            if (state.status == ChatStatus.loading)
              const SizedBox(height: 8),
            // chat input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      onSubmitted: (value) async { },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      if (state.status == ChatStatus.loading)
                        return;
                      var newMessage = ConversationMessage('user', _textEditingController.text);
                      if (conversation.messages.last.role == 'user') {
                        conversation.messages.last = newMessage;
                      } else {
                        conversation.messages.add(newMessage);
                      }

                      BlocProvider.of<ChatBloc>(context).add(
                        ChatSubmitted(conversation)
                      );
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn
                      );
                    },
                  )
                ],
              )
            )
          ]
        )
      )
    );
  }

}