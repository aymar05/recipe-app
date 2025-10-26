import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

final class StorageService {
  static const bearerTokenKey = "BEARER_TOKEN";
  static const authUserKey = "AUTH_USER";

  late final FlutterSecureStorage _flutterSecureStorage;

  StorageService() {
    _flutterSecureStorage = const FlutterSecureStorage();
  }

  Future<void> init() async {
    await getAuthUser();
    await getAuthToken();
  }

  User? authUser;
  String? token;

  bool isAuthenticated() {
    return token != null && authUser != null;
  }

  Future<String?> get(String key) async {
    return await _flutterSecureStorage.read(key: key);
  }

  Future<void> setAuthToken(String value) {
    token = value;
    return set(bearerTokenKey, value);
  }

  Future<User?> getAuthUser() async {
    String? data = await get(authUserKey);
    return data != null ? authUser ??= User.fromRawJson(jsonDecode(data)) : null;
  }

  Future<String?> getAuthToken() async {
    return token ??= await get(bearerTokenKey);
  }

  Future<void> setAuthUser(User user) async {
    authUser = user;
    await set(authUserKey, user.toRawJson());
  }

  Future<void> set(String key, String value) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }

  Future<void> clear() async {
    await _flutterSecureStorage.deleteAll();
  }
}
