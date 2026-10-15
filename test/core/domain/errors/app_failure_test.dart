import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';

void main() {
  group('mapToAppFailure', () {
    test('passes through existing AppFailure', () {
      const failure = TimeoutFailure('slow');
      expect(mapToAppFailure(failure), same(failure));
    });

    test('maps connection errors to NetworkFailure', () {
      final failure = mapToAppFailure(
        DioException(
          requestOptions: RequestOptions(path: '/stories'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test('maps timeouts to TimeoutFailure', () {
      final failure = mapToAppFailure(
        DioException(
          requestOptions: RequestOptions(path: '/stories'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      expect(failure, isA<TimeoutFailure>());
    });

    test('maps 401 to UnauthorizedFailure', () {
      final failure = mapToAppFailure(
        DioException(
          requestOptions: RequestOptions(path: '/stories'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/stories'),
            statusCode: 401,
          ),
        ),
      );
      expect(failure, isA<UnauthorizedFailure>());
    });

    test('maps 400 to ValidationFailure using server message', () {
      final failure = mapToAppFailure(
        DioException(
          requestOptions: RequestOptions(path: '/stories'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/stories'),
            statusCode: 400,
            data: {'message': 'Title is required'},
          ),
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Title is required');
    });

    test('maps Google sign-in cancel to CancelledFailure', () {
      final failure = mapToAppFailure(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'The user canceled the sign-in flow.',
        ),
      );
      expect(failure, isA<CancelledFailure>());
    });

    test('maps Google sign-in interrupt to CancelledFailure', () {
      final failure = mapToAppFailure(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.interrupted,
        ),
      );
      expect(failure, isA<CancelledFailure>());
    });

    test('maps Apple sign-in cancel to CancelledFailure', () {
      final failure = mapToAppFailure(
        const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: 'The user canceled the authorization attempt',
        ),
      );
      expect(failure, isA<CancelledFailure>());
    });

    test('maps 500 to ServerFailure', () {
      final failure = mapToAppFailure(
        DioException(
          requestOptions: RequestOptions(path: '/stories'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/stories'),
            statusCode: 500,
          ),
        ),
      );
      expect(failure, isA<ServerFailure>());
    });
  });
}
