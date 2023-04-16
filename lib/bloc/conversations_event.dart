import 'package:equatable/equatable.dart';

import '../models/models.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object> get props => [];
}

class ConversationsRequested extends ConversationsEvent {
  const ConversationsRequested();
}

class ConversationDeleted extends ConversationsEvent {
  const ConversationDeleted(this.conversationIndex);

  final ConversationIndex conversationIndex;

  @override
  List<Object> get props => [conversationIndex];
}
