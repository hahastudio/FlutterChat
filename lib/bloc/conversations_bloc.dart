import 'package:bloc/bloc.dart';

import '../services/chat_service.dart';
import 'conversations_state.dart';
import 'conversations_event.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc({
    required ChatService chatService
  }) :
    _chatService = chatService,
    super(const ConversationsState())
  {
    on<ConversationsRequested>(_onRequested);
    on<ConversationDeleted>(_onDeleted);
  }

  final ChatService _chatService;

  Future _onRequested(
    ConversationsRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(state.copyWith(status: ConversationsStatus.loading));
    emit(state.copyWith(conversations: _chatService.getConversationList(), status: ConversationsStatus.success));
  }

  Future _onDeleted(
    ConversationDeleted event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(state.copyWith(status: ConversationsStatus.loading));
    await _chatService.removeConversationById(event.conversationIndex.id);
    emit(state.copyWith(conversations: _chatService.getConversationList(), status: ConversationsStatus.success));
  }

}