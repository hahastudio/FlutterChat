import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class SafeHttpClient extends http.BaseClient {
  final RetryClient _inner;

  SafeHttpClient(http.Client httpClient) :
      _inner = RetryClient(httpClient,
        when: (response) => response.statusCode >= 500
      );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.headers.containsKey('user-agent')) {
      request.headers.remove('user-agent');
    }
    return _inner.send(request);
  }
}
