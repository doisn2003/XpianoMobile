import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Yêu cầu gửi mã OTP đến email
  Future<Either<Failure, void>> sendOtp(String email);

  /// Xác thực OTP và trả về Dữ liệu User (Lưu Token ngầm bên trong Repository)
  Future<Either<Failure, User>> loginWithOtp(String email, String otp, String role);

  /// Xác thực bằng Email và Password
  Future<Either<Failure, User>> login(String email, String password, String role);

  /// Đăng ký bằng OTP và tự động đăng nhập
  Future<Either<Failure, User>> registerWithOtp(
      String email, String otp, String password, String fullName, String phone, String role, String dob);

  /// Lấy thông tin phiên đăng nhập hiện tại từ API (dựa trên cache Token)
  Future<Either<Failure, User>> getCurrentUser();

  /// Cập nhật thông tin Profile cá nhân
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data);

  /// Đăng xuất khỏi thiết bị
  Future<Either<Failure, void>> logout();
}
