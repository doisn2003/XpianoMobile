import 'package:equatable/equatable.dart';

class CourseTeacher extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? role;

  const CourseTeacher({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.role,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, role];
}

class Course extends Equatable {
  final String id;
  final String teacherId;
  final String title;
  final String? description;
  final int price;
  final int durationWeeks;
  final int sessionsPerWeek;
  final int maxStudents;
  final String? startDate;
  final List<Map<String, dynamic>> schedule;
  final String? thumbnailUrl;
  final String? coverUrl;
  final String? demoVideoUrl;
  final bool isOnline;
  final String? location;
  final String status;
  final int enrolledCount;
  final CourseTeacher? teacher;
  final String? createdAt;

  const Course({
    required this.id,
    required this.teacherId,
    required this.title,
    this.description,
    this.price = 0,
    this.durationWeeks = 4,
    this.sessionsPerWeek = 2,
    this.maxStudents = 10,
    this.startDate,
    this.schedule = const [],
    this.thumbnailUrl,
    this.coverUrl,
    this.demoVideoUrl,
    this.isOnline = true,
    this.location,
    this.status = 'draft',
    this.enrolledCount = 0,
    this.teacher,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, teacherId, title, description, price, durationWeeks,
        sessionsPerWeek, maxStudents, startDate, schedule,
        thumbnailUrl, coverUrl, status, enrolledCount, teacher,
      ];
}

class CourseSession extends Equatable {
  final String id;
  final String? courseId;
  final String? teacherId;
  final String title;
  final String? description;
  final String scheduledAt;
  final int durationMinutes;
  final String? roomId;
  final int maxParticipants;
  final String status;

  const CourseSession({
    required this.id,
    this.courseId,
    this.teacherId,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.roomId,
    this.maxParticipants = 10,
    this.status = 'scheduled',
  });

  @override
  List<Object?> get props => [id, courseId, title, scheduledAt, status];
}

class CourseEnrollment extends Equatable {
  final String id;
  final String courseId;
  final String userId;
  final String status;
  final String? createdAt;
  final CourseTeacher? user;

  const CourseEnrollment({
    required this.id,
    required this.courseId,
    required this.userId,
    this.status = 'active',
    this.createdAt,
    this.user,
  });

  @override
  List<Object?> get props => [id, courseId, userId, status];
}
