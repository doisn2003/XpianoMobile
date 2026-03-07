import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String email);
  Future<UserModel> loginWithOtp(String email, String otp, String role);
  Future<UserModel> login(String email, String password, String role);
  Future<UserModel> registerWithOtp(
      String email, String otp, String password, String fullName, String phone, String role, String dob);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
    required this.sharedPreferences,
  });

  @override
  Future<void> sendOtp(String email) async {
    try {
      await dioClient.post(
        '/auth/send-otp',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi kết nối khi gửi OTP',
      );
    } catch (e) {
      throw ServerException(message: 'Lỗi không xác định: $e');
    }
  }

  @override
  Future<UserModel> loginWithOtp(String email, String otp, String role) async {
    try {
      final response = await dioClient.post(
        '/auth/login-otp',
        data: {'email': email, 'otp': otp},
      );

      final responseData = response.data['data'];
      final token = responseData['token'];
      final userModel = UserModel.fromJson(responseData['user']);

      if (userModel.role == 'admin' || userModel.role == 'warehouse_owner') {
        throw ServerException(message: 'Phiên bản Mobile App không hỗ trợ tài khoản quản trị, vui lòng thao tác trên web.');
      }
      if (userModel.role != role) {
        throw ServerException(message: 'Tài khoản này không có quyền đăng nhập ở tab này. Vui lòng chuyển tab.');
      }

      // Lưu Token vào SharedPreferences
      await sharedPreferences.setString(AppConstants.tokenKey, token);

      return userModel;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Thông tin xác thực không đúng',
      );
    } catch (e) {
      throw ServerException(message: 'Lỗi parse dữ liệu: $e');
    }
  }

  @override
  Future<UserModel> login(String email, String password, String role) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data['data'];
      final token = responseData['token'];
      final userModel = UserModel.fromJson(responseData['user']);

      if (userModel.role == 'admin' || userModel.role == 'warehouse_owner') {
        throw ServerException(message: 'Phiên bản Mobile App không hỗ trợ tài khoản quản trị, vui lòng thao tác trên web.');
      }
      if (userModel.role != role) {
        throw ServerException(message: 'Tài khoản này không có quyền đăng nhập ở phần này. Vui lòng chuyển tab.');
      }

      // Lưu Token vào SharedPreferences
      await sharedPreferences.setString(AppConstants.tokenKey, token);

      return userModel;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Email hoặc mật khẩu không đúng',
      );
    } catch (e) {
      throw ServerException(message: 'Lỗi parse dữ liệu: $e');
    }
  }

  @override
  Future<UserModel> registerWithOtp(
      String email, String otp, String password, String fullName, String phone, String role, String dob) async {
    try {
      final response = await dioClient.post(
        '/auth/register-verify',
        data: {
          'email': email,
          'token': otp,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'date_of_birth': dob,
        },
      );

      final responseData = response.data['data'];
      final token = responseData['token'];
      final userModel = UserModel.fromJson(responseData['user']);

      // Lưu Token vào SharedPreferences
      await sharedPreferences.setString(AppConstants.tokenKey, token);

      return userModel;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Đăng ký không thành công',
      );
    } catch (e) {
      throw ServerException(message: 'Lỗi parse dữ liệu: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get('/auth/me');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Interceptor đã auto clear token và báo lỗi
        throw UnauthorizedException();
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Lỗi tải thông tin cá nhân',
      );
    } catch (e) {
      throw ServerException(message: 'Lỗi không xác định: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (_) {
      // Ignored errors for logout
    } finally {
      await sharedPreferences.remove(AppConstants.tokenKey);
    }
  }
}
