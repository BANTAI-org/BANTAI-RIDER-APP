import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'features/auth/screens/auth_gate.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await _requestStartupPermissions();
  await ensureBlePermissions();

  final authRepository = AuthRepositoryImpl(AuthRemoteDataSource(ApiClient()));
  runApp(BantaiResponderApp(authRepository: authRepository));
}

Future<void> _requestStartupPermissions() async {
  var locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
  }

  if (locationPermission == LocationPermission.denied ||
      locationPermission == LocationPermission.deniedForever) {
    debugPrint('Location permission was not granted at startup.');
  }

  try {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint('No camera is available at startup.');
      return;
    }

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );
    try {
      await controller.initialize();
    } finally {
      await controller.dispose();
    }
  } on CameraException catch (error) {
    debugPrint(
      'Camera permission was not granted at startup: '
      '${error.code}${error.description == null ? '' : ': ${error.description}'}',
    );
  }
}

Future<bool> ensureBlePermissions() async {
  final statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ].request();

  final granted = statuses.values.every((s) => s.isGranted);
  if (!granted) {
    debugPrint('Bluetooth permission was not granted: $statuses');
  }
  return granted;
}

class BantaiResponderApp extends StatelessWidget {
  const BantaiResponderApp({super.key, required this.authRepository});

  final AuthRepositoryImpl authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BANTAI Rider App',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: AuthGate(authRepository: authRepository),
    );
  }
}
