import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../widgets/widgets.dart';
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

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) => showDialog<Conversation?>(
    context: context,
    builder: (context) {
      return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
    }
  );

  Future<bool?> showDeleteConfirmDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const ConfirmDialog(
        title: 'Delete conversation',
        content: 'Would you like to delete the conversation?',
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
                              var newConversation = await showConversationDialog(context, true, conversation);
                              if (newConversation != null) {
                                await chatService.updateConversation(newConversation);
                                bloc.add(const ConversationsRequested());
                              }
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
          var newConversation = await showConversationDialog(context, false, Conversation.create());
          if (newConversation != null) {
            await chatService.updateConversation(newConversation);
            var savedConversation = chatService.getConversationById(newConversation.id)!;
            if (context.mounted)
              Navigator.of(context).push(ChatScreenPage.route(savedConversation));
            bloc.add(const ConversationsRequested());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}