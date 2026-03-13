import '../../domain/entities/course.dart';

class CourseTeacherModel extends CourseTeacher {
  const CourseTeacherModel({
    required super.id,
    required super.fullName,
    super.avatarUrl,
    super.role,
  });

  factory CourseTeacherModel.fromJson(Map<String, dynamic> json) {
    return CourseTeacherModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
    );
  }
}

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.teacherId,
    required super.title,
    super.description,
    super.price,
    super.durationWeeks,
    super.sessionsPerWeek,
    super.maxStudents,
    super.startDate,
    super.schedule,
    super.thumbnailUrl,
    super.coverUrl,
    super.demoVideoUrl,
    super.isOnline,
    super.location,
    super.status,
    super.enrolledCount,
    super.teacher,
    super.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    CourseTeacher? teacher;
    if (json['teacher'] != null && json['teacher'] is Map<String, dynamic>) {
      teacher = CourseTeacherModel.fromJson(json['teacher']);
    }

    List<Map<String, dynamic>> schedule = [];
    if (json['schedule'] != null && json['schedule'] is List) {
      schedule = (json['schedule'] as List)
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList();
    }

    return CourseModel(
      id: json['id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: _parseInt(json['price']),
      durationWeeks: _parseInt(json['duration_weeks'], fallback: 4),
      sessionsPerWeek: _parseInt(json['sessions_per_week'], fallback: 2),
      maxStudents: _parseInt(json['max_students'], fallback: 10),
      startDate: json['start_date'] as String?,
      schedule: schedule,
      thumbnailUrl: json['thumbnail_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      demoVideoUrl: json['demo_video_url'] as String?,
      isOnline: json['is_online'] as bool? ?? true,
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'draft',
      enrolledCount: _parseInt(json['enrolled_count']),
      teacher: teacher,
      createdAt: json['created_at'] as String?,
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}

class CourseSessionModel extends CourseSession {
  const CourseSessionModel({
    required super.id,
    super.courseId,
    super.teacherId,
    required super.title,
    super.description,
    required super.scheduledAt,
    super.durationMinutes,
    super.roomId,
    super.maxParticipants,
    super.status,
  });

  factory CourseSessionModel.fromJson(Map<String, dynamic> json) {
    return CourseSessionModel(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString(),
      teacherId: json['teacher_id']?.toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      scheduledAt: json['scheduled_at'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      roomId: json['room_id'] as String?,
      maxParticipants: json['max_participants'] as int? ?? 10,
      status: json['status'] as String? ?? 'scheduled',
    );
  }
}

class CourseEnrollmentModel extends CourseEnrollment {
  const CourseEnrollmentModel({
    required super.id,
    required super.courseId,
    required super.userId,
    super.status,
    super.createdAt,
    super.user,
  });

  factory CourseEnrollmentModel.fromJson(Map<String, dynamic> json) {
    CourseTeacher? user;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      user = CourseTeacherModel.fromJson(json['user']);
    }

    return CourseEnrollmentModel(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String?,
      user: user,
    );
  }
}
