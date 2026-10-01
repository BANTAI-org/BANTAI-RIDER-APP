import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'features/auth/screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final authRepository = AuthRepositoryImpl(AuthRemoteDataSource(ApiClient()));
  runApp(BantaiResponderApp(authRepository: authRepository));
}

class BantaiResponderApp extends StatelessWidget {
  const BantaiResponderApp({super.key, required this.authRepository});

  final AuthRepositoryImpl authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BANTAI Rider App',
      theme: AppTheme.light,
      home: LoginPage(authRepository: authRepository),
    );
  }
}
