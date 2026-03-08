import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/network/supabase_client.dart';
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
  // Lưu ý: CreatePostBloc được provide ở cấp Screen — không đăng ký ở đây.
}

