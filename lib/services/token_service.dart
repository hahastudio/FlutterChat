import 'package:tiktoken/tiktoken.dart';

import '../models/models.dart';
import 'local_storage_service.dart';

class TokenService {
  static const Map<String, int> _tokenLimit = {
    'gpt-3.5-turbo': 4096,
    'gpt-4': 8192,
    'gpt-4-32k': 32768
  };

  static int getTokenLimit() {
    return _tokenLimit[LocalStorageService().model] ?? 0;
  }

  static int getToken(String message) {
    final encoding = encodingForModel(LocalStorageService().model);
    if (message.isNotEmpty) {
      return encoding.encode(message).length;
    }
    return 0;
  }

  static int getMessagesToken(Conversation conversation) {
    int tokens = 0;
    for (final m in conversation.messages) {
      if (m.content.isNotEmpty) {
        tokens += getToken(m.content);
      }
    }
    return tokens;
  }

  static List<ConversationMessage> getEffectiveMessages(Conversation conversation, String pendingMessage) {
    if (conversation.messages.isEmpty)
      return [];
    int remainingToken = getTokenLimit() - getToken(conversation.systemMessage) - getToken(pendingMessage);
    if (remainingToken <= 0)
      return [];
    int historyCount = LocalStorageService().historyCount;
    // newest user message doesn't belong to history
    if ((pendingMessage.isNotEmpty) || (conversation.messages.isNotEmpty && conversation.messages.last.role == 'user'))
      historyCount += 1;
    List<ConversationMessage> effectiveMessages = [];
    for (final m in conversation.messages.reversed) {
      if (effectiveMessages.length >= historyCount)
        break;
      if (m.content.isEmpty) {
        effectiveMessages.insert(0, m);
      } else {
        var token = getToken(m.content);
        if (remainingToken < token) {
          break;
        } else {
          effectiveMessages.insert(0, m);
          remainingToken -= token;
        }
      }
    }
    return effectiveMessages;
  }

  static int getEffectiveMessagesToken(Conversation conversation, String pendingMessage) {
    if (conversation.messages.isEmpty)
      return 0;
    int remainingToken = getTokenLimit() - getToken(conversation.systemMessage)  - getToken(pendingMessage);
    if (remainingToken <= 0)
      return 0;
    int effectiveToken = 0;
    int historyCount = LocalStorageService().historyCount;
    // newest user message doesn't belong to history
    if ((pendingMessage.isNotEmpty) || (conversation.messages.isNotEmpty && conversation.messages.last.role == 'user'))
      historyCount += 1;
    List<ConversationMessage> effectiveMessages = [];
    for (final m in conversation.messages.reversed) {
      if (effectiveMessages.length >= historyCount)
        break;
      if (m.content.isEmpty) {
        effectiveMessages.insert(0, m);
      } else {
        var token = getToken(m.content);
        if (remainingToken < token) {
          break;
        } else {
          effectiveMessages.insert(0, m);
          remainingToken -= token;
          effectiveToken += token;
        }
      }
    }
    return effectiveToken;
  }
}