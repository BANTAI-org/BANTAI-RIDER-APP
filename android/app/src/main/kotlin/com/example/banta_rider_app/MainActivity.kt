package com.example.banta_rider_app

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bantai/hotspot_settings")
            .setMethodCallHandler { call, result ->
                if (call.method == "open") {
                    startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS))
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
