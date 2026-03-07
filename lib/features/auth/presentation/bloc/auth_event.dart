import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSendOtpRequested extends AuthEvent {
  final String email;

  const AuthSendOtpRequested(this.email);

  @override
  List<Object> get props => [email];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String otp;
  final String role;

  const AuthLoginRequested(this.email, this.otp, this.role);

  @override
  List<Object> get props => [email, otp, role];
}

class AuthPasswordLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;

  const AuthPasswordLoginRequested(this.email, this.password, this.role);

  @override
  List<Object> get props => [email, password, role];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String fullName;
  final String phone;
  final String role;
  final String dob;

  const AuthRegisterRequested({
    required this.email,
    required this.otp,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.dob,
  });

  @override
  List<Object> get props => [email, otp, password, fullName, phone, role, dob];
}

class AuthLogoutRequested extends AuthEvent {}
