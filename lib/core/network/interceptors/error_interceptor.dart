import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  final Logger logger;

  ErrorInterceptor({required this.logger});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('API Response Error', error: err);

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ServerException(message: 'Hết thời gian kết nối. Vui lòng thử lại.');
      case DioExceptionType.badResponse:
        int? statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 401:
            // TODO: Thông báo qua event bus hoặc Stream để bloc/UI xử lý force logout
            logger.w('401 Unauthorized - Yêu cầu đăng nhập lại.');
            // Gửi Exception cụ thể
            throw UnauthorizedException();
          case 403:
            throw ServerException(message: 'Không có quyền truy cập.');
          case 404:
            throw ServerException(message: 'Không tìm thấy dữ liệu.');
          case 500:
          case 502:
          case 503:
          case 504:
            throw ServerException(message: 'Lỗi máy chủ. Vui lòng thử lại sau.');
          default:
            final errorMessage =
                err.response?.data?['message'] ?? 'Lỗi không xác định: $statusCode';
            throw ServerException(message: errorMessage.toString());
        }
      case DioExceptionType.cancel:
        throw ServerException(message: 'Yêu cầu đã bị hủy.');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          throw NetworkException(message: 'Không có kết nối Internet.');
        }
        throw ServerException(message: 'Lỗi không mong muốn đã xảy ra.');
      default:
        throw ServerException(message: 'Đã xảy ra lỗi.');
    }
  }
}
