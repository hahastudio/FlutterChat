import 'package:equatable/equatable.dart';

import '../models/models.dart';

enum ConversationsStatus { initial, loading, success, failure }

class ConversationsState extends Equatable {
  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
  });

  final ConversationsStatus status;
  final List<ConversationIndex> conversations;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationIndex>? conversations
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations
    );
  }

  @override
  List<Object?> get props => [status, conversations];
}