import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/network_settings.dart';
import '../storage/auth_token_storage.dart';

class ApiClient {
  ApiClient({http.Client? client, AuthTokenStorage? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final http.Client _client;
  final AuthTokenStorage _tokenStorage;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  {bool authenticated = true}) async {
    final headers = await _headers(authenticated);
    final response = await _client
        .post(
          Uri.parse('${NetworkSettings.baseUrl}$path'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(NetworkSettings.requestTimeout);

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        decoded['message']?.toString() ?? 'The request failed.',
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  {bool authenticated = true}) async {
    final headers = await _headers(authenticated);
    final response = await _client
        .put(
          Uri.parse('${NetworkSettings.baseUrl}$path'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(NetworkSettings.requestTimeout);

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        decoded['message']?.toString() ?? 'The request failed.',
      );
    }
    return decoded;
  }

  void dispose() => _client.close();

  Future<Map<String, String>> _headers(bool authenticated) async {
    final accessToken = authenticated
        ? await _tokenStorage.readAccessToken()
        : null;
    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
