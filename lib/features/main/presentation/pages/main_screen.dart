import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PlaceholderScreen(title: 'Home Feed', icon: Icons.home),
    const PlaceholderScreen(title: 'Pianos Store', icon: Icons.piano),
    const SizedBox(), // Nơi giữ Tab 2 (Nút cộng) - không render vì có BottomSheet can thiệp
    const PlaceholderScreen(title: 'Khám Phá Khóa Học', icon: Icons.explore),
    const ProfileTabScreen(), // Tab Hồ sơ sẽ check logic hiển thị UI cho Teacher
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Bắt sự kiện ấn vào nút (+) Upload Post ở giữa
      _showUploadOptions();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Tải lên nội dung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.video_call, color: Colors.deepPurple),
                title: const Text('Quay Video mới'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Chọn ảnh/video từ thư viện'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Giữ cố định 5 tabs không bị đẩy
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.piano), label: 'Pianos'),
          BottomNavigationBarItem(
            // Nút (+) tạo điểm nhấn
            icon: Icon(Icons.add_circle, size: 40, color: Colors.deepPurple),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
        ],
      ),
    ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 24, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

/// Màn hình Hồ Sơ tích hợp Logic check Role giữa User/Teacher
class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    bool isTeacher = false;
    String userName = "Khách";
    String email = "";

    if (authState is AuthAuthenticated) {
      isTeacher = authState.user.isTeacher;
      userName = authState.user.fullName;
      email = authState.user.email;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Của Tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Basic Info
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(email),
              trailing: Chip(
                label: Text(isTeacher ? 'Giáo viên' : 'Học viên', style: const TextStyle(color: Colors.white)),
                backgroundColor: isTeacher ? Colors.orange : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options for everyone
          const ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Khóa học của tôi'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.history),
            title: Text('Lịch sử đơn hàng'),
            trailing: Icon(Icons.chevron_right),
          ),

          // Options for Teacher only (Conditional UI render)
          if (isTeacher) ...[
            const Divider(height: 40, thickness: 2),
            const Text('Khu vực Giáo viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.orange),
              title: const Text('Cập nhật Chứng chỉ'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.create, color: Colors.orange),
              title: const Text('Quản lý khóa học (CMS)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.orange),
              title: const Text('Thống kê thu nhập'),
              onTap: () {},
            ),
          ]
        ],
      ),
    );
  }
}
