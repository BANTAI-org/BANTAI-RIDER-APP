import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthCredential {
  const GoogleAuthCredential({
    required this.idToken,
    required this.email,
    required this.displayName,
  });

  final String idToken;
  final String email;
  final String? displayName;

  String? get firstName {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  String? get lastName {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return null;
    final parts = name.split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : null;
  }
}

class GoogleAuthService {
  GoogleAuthService()
    : _googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_OAUTH_CLIENT_ID']?.trim(),
      );

  final GoogleSignIn _googleSignIn;

  Future<GoogleAuthCredential?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      return await _credentialFor(account);
    } catch (error, stackTrace) {
      debugPrint('Google sign in error: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<GoogleAuthCredential?> refreshCredential() async {
    final account =
        _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) return null;
    return _credentialFor(account);
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<GoogleAuthCredential> _credentialFor(
    GoogleSignInAccount account,
  ) async {
    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google did not return an ID token.');
    }
    return GoogleAuthCredential(
      idToken: idToken,
      email: account.email,
      displayName: account.displayName,
    );
  }
}
