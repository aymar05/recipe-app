import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:recipe_app/services/storage_service.dart';

class BearerInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {
    final token = (await StorageService().getAuthToken()) ?? "";
    if (token == '') {
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    }

    request.headers[HttpHeaders.acceptHeader] = "application/json";
    request.headers[HttpHeaders.contentTypeHeader] = "application/json";
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return false;
  }
}
