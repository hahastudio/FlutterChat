import 'dart:async';
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
    await LocalStorageService().setConversationJsonById(conversation.id, jsonEncode(conversation.toJson()));
    await _upsertConversationList(conversation);
  }

  Future removeConversationById(String id) async {
    await LocalStorageService().removeConversationJsonById(id);
    await _removeConversationFromListById(id);
  }

  List<ConversationIndex> getConversationList() {
    return ConversationIndex.fromListJson(jsonDecode(LocalStorageService().conversationListJson));
  }

  Future _upsertConversationList(Conversation conversation) async {
    var conversationList = getConversationList();
    ConversationIndex c = ConversationIndex.fromConversation(conversation);
    conversationList.removeWhere((e) => e.id == conversation.id);
    conversationList.insert(0, c);
    conversationList.sort((a,b) => b.lastUpdated.compareTo(a.lastUpdated));
    LocalStorageService().conversationListJson = jsonEncode(conversationList.map((i) => i.toJson()).toList());
  }

  Future _removeConversationFromListById(String id) async {
    var conversationList = getConversationList();
    conversationList.removeWhere((e) => e.id == id);
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
      conversation.error = e.toString();
      if (conversation.error.startsWith('Exception: '))
        conversation.error = conversation.error.substring(11);
      conversation.messages.last.isError = true;
    }

    conversation.lastUpdated = DateTime.now();
    updateConversation(conversation);

    return conversation;
  }

  Stream<Conversation> getResponseStreamFromServer(Conversation conversation) {
    final conversationStream = StreamController<Conversation>();

    conversation.error = '';

    var systemMessage = ChatMessage('system', conversation.systemMessage);
    var messages = conversation.messages.map((e) => e.toChatMessage()).toList();
    messages.insert(0, systemMessage);

    try {
      var responseStream = _apiServer.chatCompletionStream(messages);
      responseStream.listen((chatStream) {
        if (chatStream.choices[0].delta.role.isNotEmpty)
          conversation.messages.add(ConversationMessage(chatStream.choices[0].delta.role, ''));
        if (chatStream.choices[0].delta.content.isNotEmpty)
          conversation.messages.last.content += chatStream.choices[0].delta.content;
        conversation.lastUpdated = DateTime.now();
        updateConversation(conversation);
        conversationStream.add(conversation);
      },
      onDone: () {
        conversationStream.close();
      });
    } catch (e) {
      // drop 'Exception: '
      conversation.error = e.toString();
      if (conversation.error.startsWith('Exception: '))
        conversation.error = conversation.error.substring(11);
      conversation.messages.last.isError = true;
      conversation.lastUpdated = DateTime.now();
      updateConversation(conversation);
      conversationStream.add(conversation);
    }

    return conversationStream.stream;
  }
}