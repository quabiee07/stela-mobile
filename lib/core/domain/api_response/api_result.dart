import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:stela_mobile/core/domain/errors/app_failure.dart';

class ApiResult<T> {
  final T? data;
  final Object? error;

  ApiResult([this.data, this.error]);

  factory ApiResult.success(T data) => ApiResult(data);

  factory ApiResult.failure(Object error, [T? data]) =>
      ApiResult(data, mapToAppFailure(error));

  bool get isSuccess => error == null;

  T? getOrElse([T? Function(Object)? defaultValue]) {
    if (data == null) {
      return defaultValue == null ? null : defaultValue(toError());
    } else {
      return data!;
    }
  }

  String toError() {
    final e = error!;
    if (e is AppFailure) {
      Logger().e('ERROR: -> ${e.message}');
      return e.message;
    }
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
          if (responseData.containsKey('message')) {
            final message = responseData['message'].toString();
            Logger().e('ERROR: -> $message');
            return message;
          }
          if (responseData.containsKey('error')) {
            final errorMessage = responseData['error'].toString();
            Logger().e('ERROR: -> $errorMessage');
            return errorMessage;
          }
        }
        return mapToAppFailure(e).message;
      } catch (parseError) {
        Logger().e('Error parsing DioException: $parseError');
        return mapToAppFailure(e).message;
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
}
