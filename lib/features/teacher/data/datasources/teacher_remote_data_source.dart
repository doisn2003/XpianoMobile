import '../../../../core/network/dio_client.dart';
import '../models/teacher_profile_model.dart';
import '../models/teacher_stats_model.dart';
import '../../../explore/data/models/course_model.dart';

abstract class TeacherRemoteDataSource {
  /// GET /api/teacher/profile
  Future<TeacherProfileModel?> getMyProfile();

  /// POST /api/teacher/profile
  Future<TeacherProfileModel> submitProfile(Map<String, dynamic> body);

  /// GET /api/courses/me/teaching
  Future<List<CourseModel>> getMyTeachingCourses();

  /// POST /api/courses
  Future<CourseModel> createCourse(Map<String, dynamic> body);

  /// PUT /api/courses/:id
  Future<CourseModel> updateCourse(String courseId, Map<String, dynamic> body);

  /// POST /api/courses/:id/publish
  Future<void> publishCourse(String courseId);

  /// GET /api/teacher/stats
  Future<TeacherStats> getStats();
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final DioClient dioClient;

  TeacherRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<TeacherProfileModel?> getMyProfile() async {
    final response = await dioClient.get('/teacher/profile');
    final data = response.data['data'];
    if (data == null) return null;
    return TeacherProfileModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<TeacherProfileModel> submitProfile(Map<String, dynamic> body) async {
    final response = await dioClient.post('/teacher/profile', data: body);
    return TeacherProfileModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<CourseModel>> getMyTeachingCourses() async {
    final response = await dioClient.get('/courses/me/teaching');
    final List data = response.data['data'] as List? ?? [];
    return data
        .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CourseModel> createCourse(Map<String, dynamic> body) async {
    final response = await dioClient.post('/courses', data: body);
    return CourseModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<CourseModel> updateCourse(
      String courseId, Map<String, dynamic> body) async {
    final response = await dioClient.put('/courses/$courseId', data: body);
    return CourseModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> publishCourse(String courseId) async {
    await dioClient.post('/courses/$courseId/publish');
  }

  @override
  Future<TeacherStats> getStats() async {
    final response = await dioClient.get('/teacher/stats');
    return TeacherStats.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
