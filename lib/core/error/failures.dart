import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi liên quan đến máy chủ hoặc logic API chung
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Lỗi liên quan đến kết nối mạng hoặc không có 3G/Wifi
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Lỗi liên quan đến xác thực (Token hết hạn/Không tồn tại)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Lỗi Token 401
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Phiên đăng nhập hết hạn.'])
      : super(message);
}
