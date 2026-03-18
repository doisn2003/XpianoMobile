import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../explore/domain/entities/course.dart';
import '../entities/assignment.dart';
import '../entities/course_notification.dart';

abstract class MyCoursesRepository {
  /// Lấy danh sách khóa học của tôi (enrolled hoặc teaching tùy role)
  Future<Either<Failure, List<Course>>> getMyCourses({required bool isTeacher});

  /// Lấy tất cả sessions cho nhiều khóa học
  Future<Either<Failure, List<CourseSession>>> getSessionsForCourses(List<String> courseIds);

  /// Lấy mock data bài tập từ JSON
  Future<List<Assignment>> getMockAssignments();

  /// Lấy mock data thông báo từ JSON
  Future<List<CourseNotification>> getMockNotifications();
}
