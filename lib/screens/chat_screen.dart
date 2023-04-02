import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../services/token_service.dart';
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
    if (TokenService.getToken(conversation.systemMessage) + TokenService.getToken(_textEditingController.text) >= TokenService.getTokenLimit())
      return;
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
                    child: SelectableText(conversation.systemMessage, maxLines: 5)
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
            // status bar
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textEditingController,
              builder: (context, value, child) {
                return SizedBox(
                  height: 24,
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('${min(TokenService.getEffectiveMessages(conversation, value.text).length, LocalStorageService().historyCount)}/${LocalStorageService().historyCount}',
                              style: const TextStyle(fontSize: 12)
                            )
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Icon(Icons.translate, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('System: ${TokenService.getToken(conversation.systemMessage)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: TokenService.getToken(conversation.systemMessage) >= TokenService.getTokenLimit() ?
                                  Theme.of(context).colorScheme.error :
                                  null
                              )
                            ),
                            const SizedBox(width: 8),
                            Text('Input: ${TokenService.getToken(value.text)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: TokenService.getToken(conversation.systemMessage) + TokenService.getToken(value.text) >= TokenService.getTokenLimit() ?
                                  Theme.of(context).colorScheme.error :
                                  null
                              )
                            ),
                            const SizedBox(width: 8),
                            Text('History: ${TokenService.getEffectiveMessagesToken(conversation, value.text)}',
                              style: const TextStyle(fontSize: 12)
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
            ),
            // chat input
            Container(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                border: InputBorder.none
                              ),
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
                                color: TokenService.getToken(conversation.systemMessage) + TokenService.getToken(value.text) >= TokenService.getTokenLimit() ?
                                  Theme.of(context).colorScheme.error :
                                  null,
                                onPressed: (state.status == ChatStatus.loading) || (value.text.isEmpty || value.text.trim().isEmpty)
                                  ? null
                                  : () => handleSend(context, conversation)
                              );
                            }
                          ),
                        ],
                      ),
                    ),
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