import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/network/supabase_client.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/feed/presentation/bloc/create_post_bloc.dart';
import 'features/feed/presentation/widgets/upload_status_banner.dart';
import 'features/main/presentation/pages/main_screen.dart';
import 'injection_container.dart' as di;

import 'core/theme/app_theme.dart';

/// Global navigator key — dùng để banner có thể navigate từ bất cứ đâu
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tải biến môi trường
  await dotenv.load(fileName: ".env");

  // Khởi động Supabase
  await AppSupabaseClient.initialize();
  
  // Khởi tạo Dependency Injection (Dio, Interceptors, Repos...)
  await di.init();

  // Khởi tạo Giám sát BLoC toàn cầu (log quá trình tạo/hủy)
  Bloc.observer = AppBlocObserver();

  // Chạy App
  runApp(const XPianoApp());
}

class XPianoApp extends StatelessWidget {
  const XPianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<CreatePostBloc>(
          // Global — upload chạy nền, sống toàn vòng đời app
          create: (_) => di.sl<CreatePostBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Xpiano App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        home: const MainScreen(),
        // Builder: wrap MỌI route — banner nổi đè lên nội dung
        builder: (context, child) {
          return Stack(
            children: [
              // Nội dung page hiện tại
              child ?? const SizedBox(),
              // Banner toàn cục — overlay nổi trên MỌI màn hình
              UploadStatusBanner(
                onViewPost: () {
                  // Pop tất cả các route pushed, quay về MainScreen
                  navigatorKey.currentState?.popUntil((route) => route.isFirst);
                  // Restore status bar style về mặc định (tối) sau khi pop
                  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ));
                  // Yêu cầu MainScreen chuyển sang tab Home + refresh
                  MainScreen.switchToHomeAndRefresh();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
