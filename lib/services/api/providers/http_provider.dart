import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';

import '../interceptors/bearer_interceptor.dart';
import '../interceptors/logging_interceptor.dart';

mixin HttpProvider {
  final httpClient = InterceptedClient.build(
    interceptors: [
      BearerInterceptor(),
      LoggingInterceptor(),
    ],
  );

  utf8Decode(final Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
