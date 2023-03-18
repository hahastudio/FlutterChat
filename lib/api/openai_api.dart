import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import '../services/local_storage_service.dart';
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

  Stream<ChatResponseStream> chatCompletionStream(List<ChatMessage> messages) {
    StreamController<ChatResponseStream> controller = StreamController<ChatResponseStream>();

    final uri = Uri.https(endPointHost, '$endPointPrefix/chat/completions');
    var headers = {
      'Authorization': 'Bearer ${LocalStorageService().apiKey}',
      'Content-Type': 'application/json'
    };
    if (LocalStorageService().organization != '') {
      headers['OpenAI-Organization'] = LocalStorageService().organization;
    }
    var requestBody = jsonEncode(ChatRequest(messages, stream: true).toJson());
    http.Request request = http.Request('POST', uri);
    request.headers.addAll(headers);
    request.body = requestBody;

    log('[OpenAiApi] ChatCompletion Stream requested');
    httpClient.send(request).then((response) {
      log('[OpenAiApi] ChatCompletion Stream response started');
      response.stream.listen((value) {
        // The stream is like:
        // data: {"choices":[{"delta":{"role":"assistant"},"index":0,"finish_reason":null}],"id":"...","object":"chat.completion.chunk","created":1679123429,"model":"gpt-3.5-turbo-0301"}
        //
        // data: {"choices":[{"delta":{"content":"你"},"index":0,"finish_reason":null}],"id":"...","object":"chat.completion.chunk","created":1679123429,"model":"gpt-3.5-turbo-0301"}
        //
        // data: {"choices":[{"delta":{"content":"好"},"index":0,"finish_reason":null}],"id":"...","object":"chat.completion.chunk","created":1679123429,"model":"gpt-3.5-turbo-0301"}
        //
        // data: [DONE]
        final String data = utf8.decode(value);
        final List<String> dataLines = data
            .split('\n')
            .where((element) => element.isNotEmpty)
            .toList();
        for (String line in dataLines) {
          if (line.startsWith('data: ')) {
            final String data = line.substring(6);
            if (data.contains('[DONE]')) {
              log('[OpenAiApi] ChatCompletion Stream response finished');
              return;
            }
            controller.add(ChatResponseStream.fromJson(jsonDecode(data)));
            return;
          }

          final error = jsonDecode(data)['error'];
          if (error != null) {
            String errorMessage = 'Error connecting OpenAI: ';
            try {
              errorMessage += error['message'];
            } catch (e) {
              errorMessage += 'Status code ${response.statusCode}';
            }
            controller.addError(Exception(errorMessage));
          }
        }
      },
      onDone: () {
        controller.close();
      },
      onError: (error, stackTrace) {
        controller.addError(error, stackTrace);
      }); // response.stream.listen
    }); // httpClient.send(request).then

    return controller.stream;
  }
}