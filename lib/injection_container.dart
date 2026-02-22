import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';

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

  //! Features
  // Nơi đây sẽ tiêm phụ thuộc các Repositories, UseCases (Ví dụ sau này: AuthRepository, PianoRepository...)
  // Các Injection sẽ theo dạng BLoC -> Use Case -> Repo -> Remote DataSource -> DioClient (bên trên)
}
