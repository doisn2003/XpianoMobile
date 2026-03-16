import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role; // 'user' hoặc 'teacher'
  final String? avatar;
  final bool isEmailVerified;
  
  // Profile Intro Fields
  final String? dateOfBirth;
  final String? occupation;
  final String? school;
  final String? location;
  final String? bio;
  final List<String>? hobbies;
  final List<String>? instruments;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatar,
    this.isEmailVerified = false,
    this.dateOfBirth,
    this.occupation,
    this.school,
    this.location,
    this.bio,
    this.hobbies,
    this.instruments,
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
        dateOfBirth,
        occupation,
        school,
        location,
        bio,
        hobbies,
        instruments,
      ];
}
