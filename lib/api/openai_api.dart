import 'dart:convert';
import 'dart:core';

import 'package:flutter_chat/models/chat.dart';
import 'package:flutter_chat/services/local_storage_service.dart';
import '../util/extend_http_client.dart';

class OpenAiApi {
  static const endPointHost = 'api.openai.com';
  static const endPointPrefix = '/v1';

  final SafeHttpClient httpClient;

  OpenAiApi(this.httpClient);

  Future<ChatResponse> chatCompletion(List<ChatMessage> messages) async {
    final uri = Uri.https(endPointHost, '$endPointPrefix/chat/completions');
    var headers = {
      'Authorization': 'Bearer ${LocalStorageService().apiKey}'
    };
    if (LocalStorageService().organization != '') {
      headers['OpenAI-Organization'] = LocalStorageService().organization;
    }

    var request = ChatRequest(messages);
    print('[OpenAiApi] ChatCompletion requested');
    var response = await httpClient.post(uri, headers: headers, body: jsonEncode(request));
    print('[OpenAiApi] ChatCompletion responded');

    if (response.statusCode != 200) {
      throw Exception('Error connecting OpenAI server: status ${response.statusCode}');
    }

    var chatResponse = ChatResponse.fromJson(jsonDecode(response.body));
    return chatResponse;
  }
}