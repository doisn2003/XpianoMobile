import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.fullName,
    required super.role,
    super.avatar,
    super.isEmailVerified,
    super.dateOfBirth,
    super.occupation,
    super.school,
    super.location,
    super.bio,
    super.hobbies,
    super.instruments,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar_url'] ?? json['avatar'],
      isEmailVerified: json['is_email_verified'] ?? json['isEmailVerified'] ?? false,
      dateOfBirth: json['date_of_birth']?.toString(),
      occupation: json['occupation']?.toString(),
      school: json['school']?.toString(),
      location: json['location']?.toString(),
      bio: json['bio']?.toString(),
      hobbies: (json['hobbies'] as List?)?.map((e) => e.toString()).toList(),
      instruments: (json['instruments'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'avatar_url': avatar,
      'is_email_verified': isEmailVerified,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (occupation != null) 'occupation': occupation,
      if (school != null) 'school': school,
      if (location != null) 'location': location,
      if (bio != null) 'bio': bio,
      if (hobbies != null) 'hobbies': hobbies,
      if (instruments != null) 'instruments': instruments,
    };
  }
}
