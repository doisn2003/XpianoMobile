import '../../data/models/teacher_profile_model.dart';
import '../../data/models/teacher_stats_model.dart';
import '../../../explore/data/models/course_model.dart';

/// Abstract repository cho Teacher domain.
abstract class TeacherRepository {
  Future<TeacherProfileModel?> getMyProfile();
  Future<TeacherProfileModel> submitProfile(Map<String, dynamic> body);
  Future<List<CourseModel>> getMyTeachingCourses();
  Future<CourseModel> createCourse(Map<String, dynamic> body);
  Future<CourseModel> updateCourse(String courseId, Map<String, dynamic> body);
  Future<void> publishCourse(String courseId);
  Future<TeacherStats> getStats();
}
