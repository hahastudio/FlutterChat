import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) => showDialog<Conversation?>(
    context: context,
    builder: (context) {
      return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
    }
  );

  Future<bool?> showClearConfirmDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const ConfirmDialog(
        title: 'Clear conversation',
        content: 'Would you like to clear conversation history?',
      );
    },
  );

  void handleSend(BuildContext context, Conversation conversation) {
    var chatService = context.read<ChatService>();
    var newMessage = ConversationMessage('user', _textEditingController.text);
    _textEditingController.text = '';
    if (conversation.messages.isNotEmpty && conversation.messages.last.role == 'user') {
      conversation.messages.last = newMessage;
    } else {
      conversation.messages.add(newMessage);
    }
    BlocProvider.of<ChatBloc>(context).add(ChatStreamStarted(conversation));
    chatService.getResponseStreamFromServer(conversation).listen((conversation) {
      BlocProvider.of<ChatBloc>(context).add(ChatStreaming(conversation, conversation.lastUpdated));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn
      );
    },
    onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
    });
  }

  void handleRefresh(BuildContext context, Conversation conversation) {
    var chatService = context.read<ChatService>();
    if (conversation.messages.last.role == 'assistant') {
      conversation.messages.removeLast();
    }
    BlocProvider.of<ChatBloc>(context).add(ChatStreamStarted(conversation));
    chatService.getResponseStreamFromServer(conversation).listen((conversation) {
      BlocProvider.of<ChatBloc>(context).add(ChatStreaming(conversation, conversation.lastUpdated));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn
      );
    },
    onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    var conversation = state.initialConversation;
    var chatService = context.read<ChatService>();
    var chatBloc = BlocProvider.of<ChatBloc>(context);

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
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear conversation'),
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  var newConversation = await showConversationDialog(context, true, conversation);
                  if (newConversation != null) {
                    conversation.lastUpdated = DateTime.now();
                    await chatService.updateConversation(newConversation);
                    chatBloc.add(ChatLastUpdatedChanged(conversation, conversation.lastUpdated));
                  }
                  break;
                case 'clear':
                  var result = await showClearConfirmDialog(context);
                  if (result == true) {
                    conversation.messages = [];
                    conversation.lastUpdated = DateTime.now();
                    await chatService.updateConversation(conversation);
                    chatBloc.add(ChatLastUpdatedChanged(conversation, conversation.lastUpdated));
                  }
                  break;
                default:
                  break;
              }
            },
          ),
        ]
      ),
      body: SafeArea(
        child: Column(
          children: [
            // system message
            if(_showSystemMessage) Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(conversation.systemMessage)
                  )
                ],
              )
            ),
            // loading indicator
            if (state.status == ChatStatus.loading)
              const LinearProgressIndicator(),
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
                      minLines: 1,
                      maxLines: 3,
                      onSubmitted: (value) async { },
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textEditingController,
                    builder: (context, value, child) {
                      return IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: (state.status == ChatStatus.loading) || (value.text.isEmpty || value.text.trim().isEmpty)
                        ? null
                        : () => handleSend(context, conversation)
                      );
                    }
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: (state.status == ChatStatus.loading) || (conversation.messages.isEmpty)
                      ? null
                      : () => handleRefresh(context, conversation)
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