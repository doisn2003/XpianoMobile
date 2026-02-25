import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    return MaterialApp(
      title: 'Xpiano App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Bảng màu đẹp, chuẩn mực
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PlaceholderScreen(),
    );
  }
}

// Màn hình tạm để test
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xpiano Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text(
          'Nền móng BLoC & Dio đã được thiết lập!',
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
