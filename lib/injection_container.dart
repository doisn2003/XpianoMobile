import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/network/supabase_client.dart';
import 'core/services/media_upload_service.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/piano/data/datasources/piano_remote_data_source.dart';
import 'features/piano/data/repositories/piano_repository_impl.dart';
import 'features/piano/domain/repositories/piano_repository.dart';
import 'features/feed/data/datasources/post_remote_data_source.dart';
import 'features/feed/data/datasources/post_supabase_data_source.dart';
import 'features/feed/data/repositories/post_repository_impl.dart';
import 'features/feed/domain/repositories/post_repository.dart';
import 'features/feed/presentation/bloc/create_post_bloc.dart';
import 'features/explore/data/datasources/course_remote_data_source.dart';
import 'features/explore/data/repositories/course_repository_impl.dart';
import 'features/explore/domain/repositories/course_repository.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/datasources/user_search_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/bloc/edit_profile_bloc.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/profile/my_courses/domain/repositories/my_courses_repository.dart';
import 'features/profile/my_courses/data/repositories/my_courses_repository_impl.dart';
import 'features/teacher/data/datasources/teacher_remote_data_source.dart';
import 'features/teacher/data/repositories/teacher_repository_impl.dart';
import 'features/teacher/domain/repositories/teacher_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Khởi tạo Logger dùng chung
  sl.registerLazySingleton(() => Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: true,
          printEmojis: true,
        ),
      ));

  //! Core
  // Đăng ký DioClient làm nền tảng gọi API
  sl.registerLazySingleton(() => DioClient(logger: sl()));

  // Đăng ký SupabaseClient cho các API Public
  sl.registerLazySingleton(() => AppSupabaseClient.client);

  //! Features
  // --- Auth ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dioClient: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // BLoC (Global — AuthBloc cần tồn tại toàn bộ vòng đời app)
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // --- Piano ---
  sl.registerLazySingleton<PianoRemoteDataSource>(
    () => PianoRemoteDataSourceImpl(
      supabaseClient: sl(),
      dioClient: sl(),
    ),
  );

  sl.registerLazySingleton<PianoRepository>(
    () => PianoRepositoryImpl(remoteDataSource: sl()),
  );
  // Lưu ý: PianoListBloc, PianoDetailBloc, PianoOrderBloc
  // được provide ở cấp Screen (theo Strategy §5) — không đăng ký ở đây.

  // --- Feed ---
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<PostSupabaseDataSource>(
    () => PostSupabaseDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      supabaseDataSource: sl(),
    ),
  );

  // MediaUploadService
  sl.registerLazySingleton(() => MediaUploadService(postRepository: sl()));

  // CreatePostBloc — Global (upload chạy nền, cần sống toàn vòng đời app)
  sl.registerLazySingleton(() => CreatePostBloc(
    postRepository: sl(),
    uploadService: sl(),
  ));

  // --- Explore (Courses) ---
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(remoteDataSource: sl()),
  );
  // BLoCs (CourseList, CourseDetail, MyCourses, CourseSchedule, CourseOrder)
  // được provide ở cấp Screen — không đăng ký ở đây.

  // --- Chat ---
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserSearchDataSource>(
    () => UserSearchDataSourceImpl(dioClient: sl()),
  );
  // BLoCs (ConversationList, ChatRoom) được provide ở cấp Screen.

  // --- Profile ---
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => WalletBloc(repository: sl()));

  sl.registerFactory(() => EditProfileBloc(
    authRepository: sl(),
    mediaUploadService: sl(),
  ));

  // --- My Courses ---
  sl.registerLazySingleton<MyCoursesRepository>(
    () => MyCoursesRepositoryImpl(courseDataSource: sl()),
  );
  // MyCoursesBloc — provided at screen level (không đăng ký global ở đây).

  // --- Teacher ---
  sl.registerLazySingleton<TeacherRemoteDataSource>(
    () => TeacherRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(remoteDataSource: sl()),
  );
  // TeacherProfileBloc, TeacherCourseBloc, TeacherStatsBloc
  // được provide ở cấp Screen — không đăng ký global ở đây.
}

