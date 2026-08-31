import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart';

/// Attaches Firebase ID tokens to authenticated Stela API requests.
///
/// Skips public paths (currently `/health`). Token refresh is handled by
/// Firebase Auth; the latest ID token is also mirrored to [SecureTokenStorage].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    FirebaseAuth? firebaseAuth,
    this.publicPathSuffixes = const ['/health', 'health'],
  }) : _tokenStorage = tokenStorage,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final SecureTokenStorage _tokenStorage;
  final FirebaseAuth _firebaseAuth;
  final List<String> publicPathSuffixes;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublic(options.path)) {
      handler.next(options);
      return;
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $idToken';
          await _tokenStorage.saveToken(idToken);
          handler.next(options);
          return;
        }
      }

      final cached = await _tokenStorage.readToken();
      if (cached != null && cached.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $cached';
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor failed to attach token: $e\n$st');
      }
    }

    handler.next(options);
  }

  bool _isPublic(String path) {
    final normalized = path.toLowerCase();
    return publicPathSuffixes.any(
      (suffix) =>
          normalized == suffix.toLowerCase() ||
          normalized.endsWith('/${suffix.toLowerCase()}'),
    );
  }
}
