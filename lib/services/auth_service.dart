import 'dart:io';

import 'package:http_interceptor/extensions/string.dart';
import 'package:recipe_app/models/auth_response.dart';

import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import 'api/config/constants.dart';
import 'api/entities/api_response.dart';
import 'api/providers/http_provider.dart';

final class AuthService with HttpProvider {
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    final response = await httpClient.post(
      "${Constants.apiBaseUrl}/api/login".toUri(),
      body: request.toJson(),
    );

    if (response.statusCode == HttpStatus.ok) {
      final responseBody = utf8Decode(response);
      return Success(AuthResponse.fromJson(responseBody));
    } else {
      return Failure(code: response.statusCode);
    }
  }

  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    final response = await httpClient.post(
      "${Constants.apiBaseUrl}/api/register".toUri(),
      body: request.toJson(),
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      final responseBody = utf8Decode(response);
      return Success(AuthResponse.fromJson(responseBody));
    } else {
      return Failure(code: response.statusCode);
    }
  }

  Future<ApiResponse<void>> logout() async {
    final response = await httpClient.post(
      "${Constants.apiBaseUrl}/api/logout".toUri(),
    );

    if (response.statusCode == HttpStatus.ok) {
      return Success(null);
    } else {
      return Failure(code: response.statusCode);
    }
  }
}
