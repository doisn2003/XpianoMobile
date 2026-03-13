import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/course.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<Course>>> getPublicCourses({String? cursor, int limit = 20});

  Future<Either<Failure, Course>> getCourseDetail(String courseId);

  Future<Either<Failure, List<Course>>> getMyEnrolledCourses();

  Future<Either<Failure, List<Course>>> getMyTeachingCourses({String? cursor, int limit = 20});

  Future<Either<Failure, List<CourseEnrollment>>> getCourseEnrollments(String courseId);

  Future<Either<Failure, List<CourseSession>>> getCourseSessions(String courseId);

  Future<Either<Failure, Map<String, dynamic>>> createCourseOrder({
    required String courseId,
    required String paymentMethod,
  });
}
