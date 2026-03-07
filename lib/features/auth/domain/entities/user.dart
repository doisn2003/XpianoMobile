import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role; // 'user' hoặc 'teacher'
  final String? avatar;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatar,
    this.isEmailVerified = false,
  });

  bool get isTeacher => role == 'teacher';

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        role,
        avatar,
        isEmailVerified,
      ];
}
