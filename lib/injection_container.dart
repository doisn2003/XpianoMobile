import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/dio_client.dart';
import 'data/datasources/home_remote_data_source.dart';
import 'presentation/home/bloc/home_feed_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Khởi tạo Logger dùng chung (IN RA CONSOLE RẤT ĐẸP)
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
  // Đăng ký DioClient làm nền tảng gọi API cho toàn bộ ứng dụng
  sl.registerLazySingleton(() => DioClient(logger: sl()));
  
  // Đăng ký SupabaseClient để fetch Data Public
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Features
  // Home Feature
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      dioClient: sl(),
      supabaseClient: sl(),
    ),
  );
  
  sl.registerFactory(() => HomeFeedBloc(dataSource: sl()));
}
