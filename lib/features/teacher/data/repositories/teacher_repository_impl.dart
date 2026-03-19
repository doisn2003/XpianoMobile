import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_data_source.dart';
import '../models/teacher_profile_model.dart';
import '../models/teacher_stats_model.dart';
import '../../../explore/data/models/course_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TeacherProfileModel?> getMyProfile() =>
      remoteDataSource.getMyProfile();

  @override
  Future<TeacherProfileModel> submitProfile(Map<String, dynamic> body) =>
      remoteDataSource.submitProfile(body);

  @override
  Future<List<CourseModel>> getMyTeachingCourses() =>
      remoteDataSource.getMyTeachingCourses();

  @override
  Future<CourseModel> createCourse(Map<String, dynamic> body) =>
      remoteDataSource.createCourse(body);

  @override
  Future<CourseModel> updateCourse(
          String courseId, Map<String, dynamic> body) =>
      remoteDataSource.updateCourse(courseId, body);

  @override
  Future<void> publishCourse(String courseId) =>
      remoteDataSource.publishCourse(courseId);

  @override
  Future<TeacherStats> getStats() => remoteDataSource.getStats();
}
