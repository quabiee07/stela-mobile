import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stela_mobile/core/data/storage/secure_token_storage.dart';

/// Attaches Firebase ID tokens to authenticated Stela API requests.
///
/// Skips public paths (currently `/health`). A single 401 retries after a
/// forced token refresh. The latest ID token is mirrored to [SecureTokenStorage].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureTokenStorage tokenStorage,
    FirebaseAuth? firebaseAuth,
    this.publicPathSuffixes = const ['/health', 'health'],
  }) : _tokenStorage = tokenStorage,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  static const _retriedExtra = 'authRetried';

  final SecureTokenStorage _tokenStorage;
  final FirebaseAuth _firebaseAuth;
  final List<String> publicPathSuffixes;
  Dio? _dio;

  void attach(Dio dio) => _dio = dio;

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
        }
      }
      // Do not fall back to a cached token when there is no Firebase user —
      // orphaned tokens cause opaque 401s against authenticated endpoints.
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor failed to attach token: $e\n$st');
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        request.extra[_retriedExtra] == true ||
        _isPublic(request.path)) {
      handler.next(err);
      return;
    }

    final dio = _dio;
    final user = _firebaseAuth.currentUser;
    if (dio == null || user == null) {
      handler.next(err);
      return;
    }

    try {
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        handler.next(err);
        return;
      }
      await _tokenStorage.saveToken(idToken);
      request.headers['Authorization'] = 'Bearer $idToken';
      request.extra[_retriedExtra] = true;
      final response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
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
