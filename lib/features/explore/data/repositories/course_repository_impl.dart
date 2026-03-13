import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Course>>> getPublicCourses({String? cursor, int limit = 20}) async {
    try {
      final courses = await remoteDataSource.getPublicCourses(cursor: cursor, limit: limit);
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseDetail(String courseId) async {
    try {
      final course = await remoteDataSource.getCourseDetail(courseId);
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getMyEnrolledCourses() async {
    try {
      final courses = await remoteDataSource.getMyEnrolledCourses();
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getMyTeachingCourses({String? cursor, int limit = 20}) async {
    try {
      final courses = await remoteDataSource.getMyTeachingCourses(cursor: cursor, limit: limit);
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEnrollment>>> getCourseEnrollments(String courseId) async {
    try {
      final enrollments = await remoteDataSource.getCourseEnrollments(courseId);
      return Right(enrollments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseSession>>> getCourseSessions(String courseId) async {
    try {
      final sessions = await remoteDataSource.getCourseSessions(courseId);
      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createCourseOrder({
    required String courseId,
    required String paymentMethod,
  }) async {
    try {
      final result = await remoteDataSource.createCourseOrder(
        courseId: courseId,
        paymentMethod: paymentMethod,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
