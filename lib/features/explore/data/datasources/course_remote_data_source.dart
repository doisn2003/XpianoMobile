import '../../../../core/network/dio_client.dart';
import '../models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getPublicCourses({String? cursor, int limit = 20});
  Future<CourseModel> getCourseDetail(String courseId);
  Future<List<CourseModel>> getMyEnrolledCourses();
  Future<List<CourseModel>> getMyTeachingCourses({String? cursor, int limit = 20});
  Future<List<CourseEnrollmentModel>> getCourseEnrollments(String courseId);
  Future<List<CourseSessionModel>> getCourseSessions(String courseId);
  Future<Map<String, dynamic>> createCourseOrder({
    required String courseId,
    required String paymentMethod,
  });
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final DioClient dioClient;

  CourseRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CourseModel>> getPublicCourses({String? cursor, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;

    final response = await dioClient.get('/courses', queryParameters: params);
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => CourseModel.fromJson(json)).toList();
  }

  @override
  Future<CourseModel> getCourseDetail(String courseId) async {
    final response = await dioClient.get('/courses/$courseId');
    return CourseModel.fromJson(response.data['data']);
  }

  @override
  Future<List<CourseModel>> getMyEnrolledCourses() async {
    final response = await dioClient.get('/courses/me/enrolled');
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => CourseModel.fromJson(json)).toList();
  }

  @override
  Future<List<CourseModel>> getMyTeachingCourses({String? cursor, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;

    final response = await dioClient.get('/courses/me/teaching', queryParameters: params);
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => CourseModel.fromJson(json)).toList();
  }

  @override
  Future<List<CourseEnrollmentModel>> getCourseEnrollments(String courseId) async {
    final response = await dioClient.get('/courses/$courseId/enrollments');
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => CourseEnrollmentModel.fromJson(json)).toList();
  }

  @override
  Future<List<CourseSessionModel>> getCourseSessions(String courseId) async {
    final response = await dioClient.get('/sessions', queryParameters: {'course_id': courseId});
    final List data = response.data['data'] as List? ?? [];
    return data.map((json) => CourseSessionModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> createCourseOrder({
    required String courseId,
    required String paymentMethod,
  }) async {
    final response = await dioClient.post('/orders', data: {
      'type': 'course',
      'course_id': courseId,
      'payment_method': paymentMethod,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}
