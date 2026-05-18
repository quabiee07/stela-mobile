import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiResult<T> {
  final T? data;
  final dynamic error;

  ApiResult([this.data, this.error]);

  factory ApiResult.success(T data) => ApiResult(data);

  factory ApiResult.failure(dynamic error, [T? data]) => ApiResult(data, error);

  T? getOrElse([T? Function(Object)? defaultValue]) {
    if (data == null) {
      return defaultValue == null ? null : defaultValue(toError());
    } else {
      return data!;
    }
  }

  String toError() {
    final e = error!;
    if (e is DioException) {
      try {
        final responseData = e.response?.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors.first.toString();
              Logger().e('ERROR: -> $firstError');
              return firstError;
            }
          }
          // Fallback to 'message' field
          if (responseData.containsKey('message')) {
            final message = responseData['message'].toString();
            Logger().e('ERROR: -> $message');
            return message;
          }
          // Fallback to 'error' field if 'message' is not present
          if (responseData.containsKey('error')) {
            final errorMessage = responseData['error'].toString();
            Logger().e('ERROR: -> $errorMessage');
            return errorMessage;
          }
        }
        // If no specific message found in response data, fallback to the custom handler
        return handleDioException(e);
      } catch (parseError) {
        Logger().e('Error parsing DioException: $parseError');
        return handleDioException(e);
      }
    } else if (e is TimeoutException) {
      return 'Request timed out';
    } else if (e is SocketException) {
      return 'Connection could not be established. Check internet';
    } else if (e is FormatException) {
      return e.message;
    } else if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    } else if (e is String) {
      return e;
    }
    return 'Oops! An error occurred and request could not be completed';
  }

  String handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'Unable to connect. Please check your internet connection.';
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request took too long to send. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond. Please try again.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response?.statusCode);
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please contact support.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Requested resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 422:
        return 'Invalid data submitted. Please check your input.';
      case 429:
        return 'Too many requests. Please slow down and try again.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Unexpected error (${statusCode ?? 'unknown'}). Please try again.';
    }
  }

}
