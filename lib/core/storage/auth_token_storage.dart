import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_tokens.dart';

class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const userIdKey = 'user_id';

  final FlutterSecureStorage _storage;

  Future<void> save(AuthTokens tokens) async {
    final userId = _userIdFromAccessToken(tokens.accessToken);
    final writes = <Future<void>>[
      _storage.write(key: accessTokenKey, value: tokens.accessToken),
      _storage.write(key: userIdKey, value: userId),
    ];
    if (tokens.refreshToken != null) {
      writes.add(
        _storage.write(key: refreshTokenKey, value: tokens.refreshToken),
      );
    }
    await Future.wait(writes);
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: accessTokenKey);

  Future<String?> readRefreshToken() =>
      _storage.read(key: refreshTokenKey);

  Future<String?> readUserId() => _storage.read(key: userIdKey);

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: accessTokenKey),
      _storage.delete(key: refreshTokenKey),
      _storage.delete(key: userIdKey),
    ]);
  }

  String _userIdFromAccessToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('The access token is not a valid JWT.');
    }

    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic> || payload['sub'] is! String) {
        throw const FormatException('The access token has no user ID.');
      }
      return payload['sub'] as String;
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Unable to decode the access token: $error');
    }
  }
}
