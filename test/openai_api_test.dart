import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat/api/openai_api.dart';
import 'package:flutter_chat/models/chat.dart';
import 'package:flutter_chat/services/local_storage_service.dart';
import 'package:flutter_chat/util/extend_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SharedPreferences.setMockInitialValues({
    "pref_apikey": "deadbeef"
  });
  await LocalStorageService().init();

  group('Chat Completion', () {
    test('return messages when http response is successful', () async {
      final mockHTTPClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://api.openai.com/v1/chat/completions');
        var chatRequest = ChatRequest.fromJson(jsonDecode(request.body));
        expect(request.headers['Authorization'], 'Bearer deadbeef');
        expect(chatRequest.model, 'gpt-3.5-turbo-0301');
        expect(chatRequest.messages.length, 2);
        var chatResponse = {
          "id": "chatcmpl-123",
          "object": "chat.completion",
          "created": 1677652288,
          "choices": [{
            "index": 0,
            "message": {
              "role": "assistant",
              "content": "你好",
            },
            "finish_reason": "stop"
          }],
          "usage": {
            "prompt_tokens": 9,
            "completion_tokens": 12,
            "total_tokens": 21
          }
        };
        return Response(jsonEncode(chatResponse), 200, headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        });
      });

      var api = OpenAiApi(SafeHttpClient(mockHTTPClient));
      var messages = [
        ChatMessage('system', 'A helpful assistant to translate from English to Chinese.'),
        ChatMessage('user', 'translate: hello')
      ];
      var chatResponse = await api.chatCompletion(messages);
      expect(chatResponse.choices[0].message.content, isA<String>());
    });
  });
}