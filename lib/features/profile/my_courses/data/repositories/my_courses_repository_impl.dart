import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../../../core/error/failures.dart';
import '../../../../explore/data/datasources/course_remote_data_source.dart';
import '../../../../explore/domain/entities/course.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/course_notification.dart';
import '../../domain/repositories/my_courses_repository.dart';

class MyCoursesRepositoryImpl implements MyCoursesRepository {
  final CourseRemoteDataSource courseDataSource;

  MyCoursesRepositoryImpl({required this.courseDataSource});

  @override
  Future<Either<Failure, List<Course>>> getMyCourses({required bool isTeacher}) async {
    try {
      final courses = isTeacher
          ? await courseDataSource.getMyTeachingCourses()
          : await courseDataSource.getMyEnrolledCourses();
      return Right(List<Course>.from(courses));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseSession>>> getSessionsForCourses(List<String> courseIds) async {
    try {
      final List<CourseSession> allSessions = [];
      for (final courseId in courseIds) {
        final sessions = await courseDataSource.getCourseSessions(courseId);
        allSessions.addAll(sessions);
      }
      // Sắp xếp theo thời gian
      allSessions.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return Right(List<CourseSession>.from(allSessions));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<Assignment>> getMockAssignments() async {
    final jsonString = await rootBundle.loadString('lib/mockdata/assignments.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) {
      return Assignment(
        id: json['id'] as String,
        courseTitle: json['course_title'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: DateTime.parse(json['due_date'] as String),
        status: json['status'] as String? ?? 'pending',
      );
    }).toList();
  }

  @override
  Future<List<CourseNotification>> getMockNotifications() async {
    final jsonString = await rootBundle.loadString('lib/mockdata/course_notifications.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) {
      return CourseNotification(
        id: json['id'] as String,
        courseTitle: json['course_title'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        isRead: json['is_read'] as bool? ?? false,
      );
    }).toList();
  }
}
