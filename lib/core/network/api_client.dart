import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/network_settings.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
        .post(
          Uri.parse('${NetworkSettings.baseUrl}$path'),
          headers: const {'Content-Type': 'application/json'},
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

  Future<Map<String, dynamic>> put (
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
      .put(
        Uri.parse('${NetworkSettings.baseUrl}$path'),
        headers: const {'Content-Type': 'application/json'},
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
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
