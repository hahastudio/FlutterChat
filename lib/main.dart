import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'api/openai_api.dart';
import 'bloc/blocs.dart';
import 'screens/conversation_screen.dart';
import 'services/chat_service.dart';
import 'services/local_storage_service.dart';
import 'services/token_service.dart';
import 'util/extend_http_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  Bloc.observer = const AppBlocObserver();
  final openAiApi = OpenAiApi(SafeHttpClient(http.Client()));
  final chatService = ChatService(apiServer: openAiApi);

  // init token service in background
  // TODO: this doesn't help to decrease the loading time in chat screen
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  Isolate.spawn(
    (RootIsolateToken token) async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
      await LocalStorageService().init();
      TokenService.getToken('a');
    },
    rootIsolateToken,
  );

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
        home: BlocProvider(
          create: (context) => ConversationsBloc(
            chatService: context.read<ChatService>(),
            )..add(const ConversationsRequested()),
          child: const ConversationScreenPage(),
        )
      ),
    );
  }
}
