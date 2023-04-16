import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

class ConversationScreenPage extends StatelessWidget {
  const ConversationScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabletScreenPage(
      sidebar: ConversationScreen(),
      body: EmptyChatWidget(),
      mainView: TabletMainView.sidebar,
    );
  }
}

class ConversationScreen extends StatelessWidget {
  final Conversation? selectedConversation;

  const ConversationScreen({super.key, this.selectedConversation});

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) => showDialog<Conversation?>(
      context: context,
      builder: (context) {
        return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
      }
  );

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var bloc = BlocProvider.of<ConversationsBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen()
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
              ConversationListWidget(selectedConversation: selectedConversation)
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
            if (context.mounted) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pushReplacement(ChatScreenPage.route(savedConversation));
              } else {
                Navigator.of(context).push(ChatScreenPage.route(savedConversation));
              }
            }
            bloc.add(const ConversationsRequested());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}