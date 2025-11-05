import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api_auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _http;
  final Duration timeout;

  ApiClient({
    this.baseUrl = 'http://192.168.1.18:8000/api',
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _http = client ?? http.Client();

  Map<String, String> _defaultHeaders() {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  if (Get.isRegistered<ApiAuthService>()) {
    final authService = Get.find<ApiAuthService>();
    final token = authService.token; 
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
  }

  return headers;
}

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final cleanedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse(baseUrl + cleanedPath);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  Future<dynamic> getJson(String path, {Map<String, String>? params}) async {
    final uri = _buildUri(path, params);
    try {
      final resp = await _http.get(uri, headers: _defaultHeaders()).timeout(timeout);
      return _processResponse(resp);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    final uri = _buildUri(path);
    try {
      final resp = await _http
          .post(uri, headers: _defaultHeaders(), body: body == null ? null : jsonEncode(body))
          .timeout(timeout);
      return _processResponse(resp);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> putJson(String path, {Object? body}) async {
    final uri = _buildUri(path);
    try {
      final resp = await _http
          .put(uri, headers: _defaultHeaders(), body: body == null ? null : jsonEncode(body))
          .timeout(timeout);
      return _processResponse(resp);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> deleteJson(String path) async {
    final uri = _buildUri(path);
    try {
      final resp = await _http.delete(uri, headers: _defaultHeaders()).timeout(timeout);
      return _processResponse(resp);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  dynamic _processResponse(http.Response resp) {
    final code = resp.statusCode;
    if (code >= 200 && code < 300) {
      if (resp.body.isEmpty) return null;
      try {
        return jsonDecode(resp.body);
      } catch (_) {
        return resp.body;
      }
    } else {
      String msg = resp.body;
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && decoded['message'] != null) msg = decoded['message'].toString();
      } catch (_) {}
      throw ApiException(msg, statusCode: code);
    }
  }
}