import 'package:equatable/equatable.dart';

import '../models/models.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatLastUpdatedChanged extends ChatEvent {
  const ChatLastUpdatedChanged(this.conversation, this.lastUpdated);

  final DateTime lastUpdated;
  final Conversation conversation;

  @override
  List<Object> get props => [lastUpdated];
}

class ChatSubmitted extends ChatEvent {
  const ChatSubmitted(this.conversation);

  final Conversation conversation;
}

class ChatStreamStarted extends ChatEvent {
  const ChatStreamStarted(this.conversation);

  final Conversation conversation;
}

class ChatStreaming extends ChatEvent {
  const ChatStreaming(this.conversation, this.lastUpdated);

  final DateTime lastUpdated;
  final Conversation conversation;

  @override
  List<Object> get props => [lastUpdated];
}

class ChatStreamEnded extends ChatEvent {
  const ChatStreamEnded(this.conversation);

  final Conversation conversation;
}