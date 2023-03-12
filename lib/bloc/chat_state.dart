import 'package:equatable/equatable.dart';

import '../models/models.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    required this.initialConversation,
    required this.id,
    required this.title,
    required this.lastUpdated
  });

  final ChatStatus status;
  final Conversation initialConversation;
  final String id;
  final String title;
  final DateTime lastUpdated;

  ChatState copyWith({
    ChatStatus? status,
    Conversation? initialConversation,
    String? id,
    String? title,
    DateTime? lastUpdated
  }) {
    return ChatState(
      status: status ?? this.status,
      initialConversation: initialConversation ?? this.initialConversation,
      id: id ?? this.id,
      title: title ?? this.title,
      lastUpdated: lastUpdated ?? this.lastUpdated
    );
  }

  @override
  List<Object?> get props => [status, id, title, lastUpdated];
}