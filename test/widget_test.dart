// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:banta_responder_app/main.dart';
import 'package:banta_responder_app/core/network/api_client.dart';
import 'package:banta_responder_app/data/datasources/auth_remote_data_source.dart';
import 'package:banta_responder_app/data/repositories/auth_repository_impl.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    final repository = AuthRepositoryImpl(AuthRemoteDataSource(ApiClient()));
    await tester.pumpWidget(BantaiResponderApp(authRepository: repository));

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
