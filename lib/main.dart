import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/models/conversation.dart';
import 'package:flutter_chat/screens/chat_screen.dart';
import 'package:http/http.dart' as http;

import 'api/openai_api.dart';
import 'bloc/blocs.dart';
import 'screens/setting_screen.dart';
import 'services/chat_service.dart';
import 'services/local_storage_service.dart';
import 'util/extend_http_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  Bloc.observer = const AppBlocObserver();
  final openAiApi = OpenAiApi(SafeHttpClient(http.Client()));
  final chatService = ChatService(apiServer: openAiApi);

  runZonedGuarded(
    () => runApp(App(chatService: chatService)),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}

class App extends StatelessWidget {
  const App({super.key, required this.chatService});

  final ChatService chatService;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: chatService,
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const AppView()
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {

    var chatService = context.read<ChatService>();
    var conversation = chatService.getConversationById('default');
    var testConversation = conversation ?? Conversation(
      'default',
      'Testing chat',
      'A helpful assistant',
      [
        ConversationMessage('user', 'Hello!'),
        ConversationMessage('assistant', 'Hello there, how may I assist you today?'),
      ]
    );

    return Scaffold(
      appBar: AppBar(
          title: const Text('Chat'),
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
      body: Center(
          child: TextButton(
            child: const Text('Go Chat'),
            onPressed: () {
              Navigator.of(context).push(ChatScreenPage.route(testConversation));
            },
          )
      ),
    );
  }
}
