import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkSettings {
  const NetworkSettings._();

  static String get baseUrl => _required('API_BASE_URL');

  static Duration get requestTimeout => Duration(
    seconds: int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '') ?? 15,
  );

  static const String signInPath = '/auth/local/signin';
  static const String driverRegistrationPath = '/drivers/register';
  static const String refreshPath = '/auth/refresh';

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$key is missing from .env');
    }
    return value;
  }
}
