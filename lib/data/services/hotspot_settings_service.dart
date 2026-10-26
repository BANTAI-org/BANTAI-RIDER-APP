import 'package:flutter/services.dart';

class HotspotSettingsService {
  static const _channel = MethodChannel('bantai/hotspot_settings');

  static Future<void> open() async {
    await _channel.invokeMethod<void>('open');
  }
}
