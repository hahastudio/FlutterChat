import './chat.dart';
import '../util/type_converter.dart';

class Conversation {
  final String id;
  String title;
  DateTime lastUpdated;
  String systemMessage;
  List<ConversationMessage> messages;
  String error;

  Conversation(
      this.id,
      this.title,
      this.systemMessage,
      this.messages,
      {
        DateTime? lastUpdated,
        this.error = ''
      }) : lastUpdated = lastUpdated ?? DateTime.now();

  static Conversation fromJson(Map<String, dynamic> json) =>
      Conversation(
          json['id'],
          json['title'],
          json['system_message'],
          ConversationMessage.fromListJson(json['messages']),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(doubleToInt(json['last_updated']) * 1000),
          error: json['error']
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'last_updated': lastUpdated.millisecondsSinceEpoch / 1000,
    'system_message': systemMessage,
    'messages': messages.map((m) => m.toJson()).toList(),
    'error': error
  };
}

class ConversationMessage {
  final String role;
  final String content;
  bool isError;

  ConversationMessage(this.role, this.content, { this.isError = false });

  static ConversationMessage fromChatMessage(ChatMessage message) =>
    ConversationMessage(message.role, message.content);

  ChatMessage toChatMessage() =>
    ChatMessage(role, content);

  static ConversationMessage fromJson(Map<String, dynamic> json) =>
      ConversationMessage(json['role'], json['content'], isError: json['is_error']);

  static List<ConversationMessage> fromListJson(List json) {
    final messages = <ConversationMessage>[];
    for (final item in json) {
      messages.add(ConversationMessage.fromJson(item));
    }
    return messages;
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'is_error': isError
  };
}

class ConversationIndex {
  final String id;
  String title;
  DateTime lastUpdated;

  ConversationIndex(
      this.id,
      this.title,
      {
        DateTime? lastUpdated
      }) : lastUpdated = lastUpdated ?? DateTime.now();

  static ConversationIndex fromConversation(Conversation c) =>
      ConversationIndex(c.id, c.title, lastUpdated: c.lastUpdated);

  static ConversationIndex fromJson(Map<String, dynamic> json) =>
      ConversationIndex(
          json['id'],
          json['title'],
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(doubleToInt(json['last_updated']) * 1000),
      );

  static List<ConversationIndex> fromListJson(List json) {
    final indices = <ConversationIndex>[];
    for (final item in json) {
      indices.add(ConversationIndex.fromJson(item));
    }
    return indices;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'last_updated': lastUpdated.millisecondsSinceEpoch / 1000,
  };
}