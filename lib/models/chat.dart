import '../util/type_converter.dart';

/// Document: https://platform.openai.com/docs/api-reference/chat

class ChatMessage {
  /// either “system”, “user”, or “assistant”
  final String role;
  /// the content of the message
  final String content;

  ChatMessage(this.role, this.content);

  static ChatMessage fromJson(Map<String, dynamic> json) =>
      ChatMessage(json['role'], json['content']);

  static List<ChatMessage> fromListJson(List json) {
    final messages = <ChatMessage>[];
    for (final item in json) {
      messages.add(ChatMessage.fromJson(item));
    }
    return messages;
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content
  };
}

class ChatRequest {
  /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
  final String model = 'gpt-3.5-turbo-0301';
  /// The messages to generate chat completions for
  final List<ChatMessage> messages;
  ///
  final bool stream;

  ChatRequest(this.messages, {this.stream = false});

  static ChatRequest fromJson(Map<String, dynamic> json) =>
    ChatRequest(ChatMessage.fromListJson(json['messages']));

  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((m) => m.toJson()).toList(),
    'stream': stream
  };
}

class ChatResponseChoice {
  final int index;
  final ChatMessage message;
  final String finishReason;

  ChatResponseChoice(this.index, this.message, this.finishReason);

  static ChatResponseChoice fromJson(Map<String, dynamic> json) =>
    ChatResponseChoice(json['index'],
      ChatMessage.fromJson(json['message']),
      json['finish_reason'] ?? ''
    );

  static List<ChatResponseChoice> fromListJson(List json) {
    final choices = <ChatResponseChoice>[];
    for (final item in json) {
      choices.add(ChatResponseChoice.fromJson(item));
    }
    return choices;
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'message': message.toJson(),
    'finish_reason': finishReason
  };
}

class ChatResponseUsage {
  final int promptTokens = 0;
  final int completionTokens = 0;
  final int totalTokens = 0;

  ChatResponseUsage(promptTokens, completionTokens, totalTokens);

  static ChatResponseUsage fromJson(Map<String, dynamic> json) =>
    ChatResponseUsage(json['prompt_tokens'],
      json['completion_tokens'],
      json['total_tokens']
    );
}

class ChatResponse {
  final String id;
  final String object;
  final DateTime created;
  final List<ChatResponseChoice> choices;
  final ChatResponseUsage usage;

  ChatResponse(this.id, this.object, this.created, this.choices, this.usage);

  static ChatResponse fromJson(Map<String, dynamic> json) =>
    ChatResponse(json['id'],
      json['object'],
      DateTime.fromMillisecondsSinceEpoch(doubleToInt(json['created']) * 1000),
      ChatResponseChoice.fromListJson(json['choices']),
      ChatResponseUsage.fromJson(json['usage'])
    );
}

class ChatResponseDelta {
  final String role;
  final String content;

  ChatResponseDelta(this.role, this.content);

  static ChatResponseDelta fromJson(Map<String, dynamic> json) =>
    ChatResponseDelta(
      json['role'] ?? '',
      json['content'] ?? ''
    );
}

class ChatResponseChoiceStream {
  final int index;
  final ChatResponseDelta delta;
  final String finishReason;

  ChatResponseChoiceStream(this.index, this.delta, this.finishReason);

  static ChatResponseChoiceStream fromJson(Map<String, dynamic> json) =>
    ChatResponseChoiceStream(json['index'],
      ChatResponseDelta.fromJson(json['delta']),
      json['finish_reason'] ?? ''
    );

  static List<ChatResponseChoiceStream> fromListJson(List json) {
    final choices = <ChatResponseChoiceStream>[];
    for (final item in json) {
      choices.add(ChatResponseChoiceStream.fromJson(item));
    }
    return choices;
  }
}

class ChatResponseStream {
  final String id;
  final String object;
  final DateTime created;
  final List<ChatResponseChoiceStream> choices;

  ChatResponseStream(this.id, this.object, this.created, this.choices);

  static ChatResponseStream fromJson(Map<String, dynamic> json) =>
    ChatResponseStream(json['id'],
      json['object'],
      DateTime.fromMillisecondsSinceEpoch(doubleToInt(json['created']) * 1000),
      ChatResponseChoiceStream.fromListJson(json['choices']),
    );
}