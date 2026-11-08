import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bantai_rider_app/core/constants/network_settings.dart';
import 'package:bantai_rider_app/core/network/api_client.dart';
import 'package:bantai_rider_app/data/datasources/auth_remote_data_source.dart';
import 'package:bantai_rider_app/domain/entities/driver_registration.dart';

void main() {
  late http.Request request;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  AuthRemoteDataSource dataSource({
    Map<String, dynamic> response = const {},
    int statusCode = 200,
  }) {
    final client = MockClient((incoming) async {
      request = incoming;
      return http.Response(jsonEncode(response), statusCode);
    });
    return AuthRemoteDataSource(
      ApiClient(client: client, baseUrl: NetworkSettings.baseUrl),
    );
  }

  Map<String, dynamic> body() =>
      jsonDecode(request.body) as Map<String, dynamic>;

  test('login posts credentials and parses tokens', () async {
    final tokens = await dataSource(
      response: {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
      },
    ).login(email: 'rider@example.com', password: 'password');

    expect(request.url.path, NetworkSettings.signInPath);
    expect(body(), {'email': 'rider@example.com', 'password': 'password'});
    expect(request.headers.containsKey('cookie'), isFalse);
    expect(tokens.accessToken, 'access-token');
    expect(tokens.refreshToken, 'refresh-token');
  });

  test('Google login posts the ID token', () async {
    await dataSource(
      response: {'accessToken': 'access-token'},
    ).loginWithGoogle(idToken: 'google-id-token');

    expect(request.url.path, NetworkSettings.googleSignInPath);
    expect(body(), {'idToken': 'google-id-token'});
  });

  test('OTP send posts the mobile number', () async {
    await dataSource().otpSend(contactNumber: '+639171234567');

    expect(request.url.path, NetworkSettings.otpSendPath);
    expect(body(), {'m_number': '+639171234567'});
  });

  test('OTP signup verification posts the number and code', () async {
    await dataSource().otpVerifySignup(
      contactNumber: '+639171234567',
      otpCode: '123456',
    );

    expect(request.url.path, NetworkSettings.otpVerificationSignupPath);
    expect(body(), {'m_number': '+639171234567', 'otp_code': '123456'});
  });

  test('signup posts the complete registration payload', () async {
    final registration = DriverRegistration(
      firstName: 'Ana',
      lastName: 'Rider',
      dateOfBirth: '1990-01-01',
      address: 'Manila',
      mobileNumber: '+639171234567',
      email: 'ana@example.com',
      password: 'password',
      serviceProvider: 'BANTAI',
      serviceId: 'service-1',
      licenseNumber: 'LIC-1',
      licenseExpiresAt: '2030-01-01',
      yearsRiding: 5,
      plateNumber: 'ABC123',
      vehicleModel: 'Model X',
      vehicleColor: 'Black',
      bloodType: 'O+',
      medicalConditions: 'None',
      emergencyContacts: const [
        {'name': 'Contact', 'number': '+639181234567'},
      ],
      dataSharingConsent: true,
    );

    final tokens = await dataSource(
      response: {'accessToken': 'access-token'},
    ).signup(registration);

    expect(request.url.path, NetworkSettings.driverRegistrationPath);
    expect(body(), registration.toJson());
    expect(tokens.accessToken, 'access-token');
  });

  test('forgot-password OTP uses email and parses resend delay', () async {
    final resendAfter = await dataSource(
      response: {'resend_after_seconds': 45.8},
    ).otpForgotPasswordOtpSend(email: 'rider@example.com');

    expect(request.url.path, NetworkSettings.forgotPasswordRequestPath);
    expect(body(), {'email': 'rider@example.com'});
    expect(resendAfter, 45);
  });

  test('forgot-password OTP uses contact number and defaults delay', () async {
    final resendAfter = await dataSource(
      response: {},
    ).otpForgotPasswordOtpSend(contactNumber: '+639171234567');

    expect(body(), {'m_number': '+639171234567'});
    expect(resendAfter, 30);
  });

  test('forgot-password OTP rejects missing identity', () {
    expect(
      () => dataSource().otpForgotPasswordOtpSend(),
      throwsArgumentError,
    );
  });

  test('forgot-password verification returns the reset token', () async {
    final resetToken = await dataSource(
      response: {'reset_token': 'reset-token'},
    ).verifyForgotPasswordOtp(
      contactNumber: '+639171234567',
      otpCode: '123456',
    );

    expect(request.url.path, NetworkSettings.forgotPasswordVerifyPath);
    expect(body(), {'m_number': '+639171234567', 'otp_code': '123456'});
    expect(resetToken, 'reset-token');
  });

  test('refresh sends the refresh token as a cookie', () async {
    final tokens = await dataSource(
      response: {
        'accessToken': 'new-access-token',
        'refreshToken': 'new-refresh-token',
      },
    ).refresh(refreshToken: 'stored-refresh-token');

    expect(request.url.path, NetworkSettings.refreshPath);
    expect(request.headers['cookie'], 'refresh_token=stored-refresh-token');
    expect(body(), isEmpty);
    expect(tokens.accessToken, 'new-access-token');
  });

  test('logout posts to the authenticated logout endpoint', () async {
    await dataSource().logout();

    expect(request.url.path, NetworkSettings.logoutPath);
    expect(body(), isEmpty);
  });

  test('reset password posts the reset token and new password', () async {
    await dataSource().resetPassword(
      resetToken: 'reset-token',
      newPassword: 'new-password',
    );

    expect(request.url.path, NetworkSettings.forgotPasswordResetPath);
    expect(
      body(),
      {'reset_token': 'reset-token', 'new_password': 'new-password'},
    );
  });

  test('propagates API errors', () async {
    expect(
      () => dataSource(
        response: {'message': 'Invalid credentials'},
        statusCode: 401,
      ).login(email: 'rider@example.com', password: 'wrong'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.message, 'message', 'Invalid credentials'),
      ),
    );
  });
}
