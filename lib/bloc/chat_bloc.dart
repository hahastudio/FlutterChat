import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart';
import '../services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatService chatService,
    required Conversation initialConversation,
  }) :
    _chatService = chatService,
    super(
      ChatState(
        initialConversation: initialConversation,
        id: initialConversation.id,
        title: initialConversation.title,
        lastUpdated: initialConversation.lastUpdated
      ),
    )
  {
    on<ChatLastUpdatedChanged>(_onLastUpdatedChanged);
    on<ChatSubmitted>(_onSubmitted);
  }

  final ChatService _chatService;

  void _onLastUpdatedChanged(
    ChatLastUpdatedChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(initialConversation: event.conversation, lastUpdated: event.lastUpdated));
  }

  Future<void> _onSubmitted(
    ChatSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(initialConversation: event.conversation, status: ChatStatus.loading));

    try {
      var newConversation = await _chatService.getResponseFromServer(event.conversation);
      emit(state.copyWith(
          initialConversation: newConversation,
          status: newConversation.messages.last.isError ? ChatStatus.failure : ChatStatus.success
      ));
    } catch (e) {
      emit(state.copyWith(initialConversation: event.conversation, status: ChatStatus.failure));
    }
  }
}