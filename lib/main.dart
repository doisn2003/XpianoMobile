import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/network/supabase_client.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'injection_container.dart' as di;

import 'core/theme/app_theme.dart';

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
          // Kiểm tra auth ngay khi app khởi động để quyết định Home vs Login
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Xpiano App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
