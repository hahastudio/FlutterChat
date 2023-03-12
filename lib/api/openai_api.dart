import 'dart:convert';
import 'dart:core';
import 'dart:developer';

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
      'Authorization': 'Bearer ${LocalStorageService().apiKey}',
      'Content-Type': 'application/json'
    };
    if (LocalStorageService().organization != '') {
      headers['OpenAI-Organization'] = LocalStorageService().organization;
    }

    var request = ChatRequest(messages);
    log('[OpenAiApi] ChatCompletion requested');
    var response = await httpClient.post(uri, headers: headers, body: jsonEncode(request.toJson()));
    log('[OpenAiApi] ChatCompletion responded');

    if (response.statusCode != 200) {
      String errorMessage = 'Error connecting OpenAI: ';
      try {
        var errorResponse = json.decode(utf8.decode(response.bodyBytes));
        errorMessage += errorResponse['error']['message'];
      } catch (e) {
        errorMessage += 'Status code ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }

    var chatResponse = ChatResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    return chatResponse;
  }
}