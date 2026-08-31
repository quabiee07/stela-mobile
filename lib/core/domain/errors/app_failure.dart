import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Typed failures for the domain/UI boundary. Never surface raw [DioException].
sealed class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Unable to connect. Check your internet.']);
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([
    super.message = 'Session expired. Please log in again.',
  ]);
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure([
    super.message = "You don't have permission to do that.",
  ]);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure([super.message = 'Please check your input and try again.']);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Requested resource was not found.']);
}

final class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'Something went wrong on our side. Please try again later.',
  ]);
}

final class CancelledFailure extends AppFailure {
  const CancelledFailure([super.message = 'Request was cancelled.']);
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([
    super.message = 'Oops! An error occurred and the request could not be completed.',
  ]);
}

AppFailure mapToAppFailure(Object error) {
  if (error is AppFailure) return error;

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkFailure();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Secure connection failed.');
      case DioExceptionType.badResponse:
        return _fromStatusCode(error.response?.statusCode, error);
    }
  }

  final text = error.toString().replaceFirst('Exception: ', '');
  if (text.isNotEmpty && text != error.runtimeType.toString()) {
    return UnexpectedFailure(text);
  }
  return const UnexpectedFailure();
}

AppFailure _fromStatusCode(int? statusCode, DioException error) {
  final serverMessage = _extractServerMessage(error.response?.data);

  switch (statusCode) {
    case 400:
    case 422:
      return ValidationFailure(serverMessage ?? 'Invalid data submitted.');
    case 401:
      return UnauthorizedFailure(serverMessage ?? 'Unauthorized. Please log in again.');
    case 403:
      return ForbiddenFailure(serverMessage ?? "Access denied.");
    case 404:
      return NotFoundFailure(serverMessage ?? 'Requested resource not found.');
    case 408:
      return const TimeoutFailure();
    case 429:
      return const ValidationFailure('Too many requests. Please slow down.');
    case 500:
    case 502:
    case 503:
    case 504:
      return ServerFailure(serverMessage ?? 'Server error. Please try again later.');
    default:
      return UnexpectedFailure(
        serverMessage ?? 'Unexpected error (${statusCode ?? 'unknown'}).',
      );
  }
}

String? _extractServerMessage(Object? data) {
  if (data is! Map) return null;
  final map = Map<String, dynamic>.from(data);
  if (map['errors'] is List && (map['errors'] as List).isNotEmpty) {
    return (map['errors'] as List).first.toString();
  }
  if (map['message'] != null) return map['message'].toString();
  if (map['error'] != null) return map['error'].toString();
  return null;
}
