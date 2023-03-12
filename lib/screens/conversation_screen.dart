import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'setting_screen.dart';

class ConversationScreenPage extends StatelessWidget {
  const ConversationScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversationScreen();
  }
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  late ScrollController _scrollController;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleEditingController;
  late TextEditingController _systemMessageEditingController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    _titleEditingController = TextEditingController();
    _systemMessageEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleEditingController.dispose();
    _systemMessageEditingController.dispose();
    super.dispose();
  }

  Future showConversationDialog(BuildContext context, bool isEdit, Conversation conversation, ChatService chatService) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
            title: Text(isEdit? 'Edit conversation' : 'New conversation'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () async {
                  if (_formKey.currentState == null || !_formKey.currentState!.validate())
                    return;
                  conversation.title = _titleEditingController.text;
                  conversation.systemMessage = _systemMessageEditingController.text;
                  if (!isEdit)
                    conversation.lastUpdated = DateTime.now();
                  await chatService.updateConversation(conversation);
                  if (context.mounted)
                    Navigator.of(context).pop();
                  if (isEdit)
                    return;
                  var savedConversation = chatService.getConversationById(conversation.id)!;
                  if (context.mounted)
                    Navigator.of(context).push(ChatScreenPage.route(savedConversation));
                },
              ),
            ],
          );
        });
      }
    );
  }

  Future<bool?> showDeleteConfirmDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete conversation'),
        content: const Text('Would you like to delete the conversation?'),
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
    },
  );

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var bloc = BlocProvider.of<ConversationsBloc>(context);
    final state = context.watch<ConversationsBloc>().state;
    var conversations = state.conversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ));
            },
          )
        ]
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    var conversationIndex = conversations[index];
                    return ListTile(
                      title: Text(conversationIndex.title, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                      onTap: () async {
                        var id = conversations[index].id;
                        var conversation = chatService.getConversationById(id);
                        if (conversation != null) {
                          if (context.mounted)
                            Navigator.of(context)
                              .push(ChatScreenPage.route(conversation))
                              .then((_) => bloc.add(const ConversationsRequested()));
                          bloc.add(const ConversationsRequested());
                        }
                      },
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              var id = conversations[index].id;
                              var conversation = chatService.getConversationById(id);
                              if (conversation == null)
                                break;
                              _titleEditingController.text = conversation.title;
                              _systemMessageEditingController.text = conversation.systemMessage;
                              await showConversationDialog(context, true, conversation, chatService);
                              bloc.add(const ConversationsRequested());
                              break;
                            case 'delete':
                              var result = await showDeleteConfirmDialog(context);
                              if (result == true)
                                bloc.add(ConversationDeleted(conversations[index]));
                              break;
                            default:
                              break;
                          }
                        },
                      ),
                    );
                  },
                )
              )
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newConversation = Conversation.create();
          _titleEditingController.text = newConversation.title;
          _systemMessageEditingController.text = newConversation.systemMessage;
          await showConversationDialog(context, false, newConversation, chatService);
          bloc.add(const ConversationsRequested());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}