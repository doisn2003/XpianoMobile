import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'presentation/main/main_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load biến môi trường
  await dotenv.load(fileName: ".env");

  // Khởi tạo Supabase Client
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

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
    // MultiBlocProvider chứa danh sách các Bloc dùng chung (Global State)
    // Tạm thời comment MultiBlocProvider vì package:nested yêu cầu danh sách providers không được rỗng
    return MaterialApp(
      title: 'Xpiano App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Hoặc ThemeMode.light theo design
      home: const MainScreen(),
    );
  }
}
