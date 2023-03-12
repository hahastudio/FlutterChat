import 'dart:convert';

import '../api/openai_api.dart';
import './local_storage_service.dart';
import '../models/models.dart';

class ChatService {

  const ChatService({
    required OpenAiApi apiServer,
  }) : _apiServer = apiServer;

  final OpenAiApi _apiServer;

  Conversation? getConversationById(String id) {
    var conversationJson = LocalStorageService().getConversationJsonById(id);
    if (conversationJson == '')
      return null;
    return Conversation.fromJson(jsonDecode(conversationJson));
  }

  Future updateConversation(Conversation conversation) async {
    conversation.lastUpdated = DateTime.now();
    await LocalStorageService().setConversationJsonById(conversation.id, jsonEncode(conversation.toJson()));
    await _upsertConversationList(conversation);
  }

  Future removeConversation(Conversation conversation) async {
    await LocalStorageService().removeConversationJsonById(conversation.id);
    await _removeConversationFromList(conversation);
  }

  List<ConversationIndex> getConversationList() {
    return ConversationIndex.fromListJson(jsonDecode(LocalStorageService().conversationListJson));
  }

  Future _upsertConversationList(Conversation conversation) async {
    var conversationList = getConversationList();
    ConversationIndex c = ConversationIndex.fromConversation(conversation);
    conversationList.removeWhere((e) => e.id == conversation.id);
    conversationList.insert(0, c);
    LocalStorageService().conversationListJson = jsonEncode(conversationList.map((i) => i.toJson()).toList());
  }

  Future _removeConversationFromList(Conversation conversation) async {
    var conversationList = getConversationList();
    conversationList.removeWhere((e) => e.id == conversation.id);
    LocalStorageService().conversationListJson = jsonEncode(conversationList.map((i) => i.toJson()).toList());
  }

  Future<Conversation> getResponseFromServer(Conversation conversation) async {
    conversation.error = '';

    var systemMessage = ChatMessage('system', conversation.systemMessage);
    var messages = conversation.messages.map((e) => e.toChatMessage()).toList();
    messages.insert(0, systemMessage);

    try {
      var response = await _apiServer.chatCompletion(messages);
      conversation.messages.add(ConversationMessage.fromChatMessage(response.choices[0].message));
    } catch (e) {
      // drop 'Exception: '
      conversation.error = e.toString().substring(11);
      conversation.messages.last.isError = true;
    }

    updateConversation(conversation);

    return conversation;
  }
}