import '../api_response/api_result.dart';

abstract class UseCase<T, P> {
  final P param;

  UseCase(this.param);

  Future<ApiResult<T>> invoke();
}