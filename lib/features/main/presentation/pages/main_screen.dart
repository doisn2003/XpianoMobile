import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../auth/presentation/widgets/auth_required_dialog.dart';
import '../../../piano/presentation/pages/piano_list_screen.dart';
import '../../../feed/presentation/pages/create_post_screen.dart';
import '../../../feed/presentation/pages/feed_screen.dart';
import '../../../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _refreshCounter = 0;

  late List<Widget> _pages = _buildPages();

  List<Widget> _buildPages() => [
    FeedScreen(key: ValueKey('feed_$_refreshCounter')),
    PianoListScreen(key: ValueKey('piano_$_refreshCounter')),
    const SizedBox(), // Nút cộng — không render
    const PlaceholderScreen(title: 'Khám Phá Khóa Học', icon: Icons.explore),
    const ProfileTabScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showUploadOptions();
    } else if (index == _currentIndex) {
      // Tap lại tab hiện tại → refresh page
      setState(() {
        _refreshCounter++;
        _pages = _buildPages();
      });
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _showUploadOptions() async {
    // Kiểm tra auth: phải đăng nhập mới được đăng bài
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final loggedIn = await AuthRequiredDialog.show(context);
      if (!loggedIn || !mounted) return;
    }

    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    
    // Nếu tạo bài viết thành công, chuyển về trang Home và refresh
    if (result == true && mounted) {
      setState(() {
        _currentIndex = 0;
        _refreshCounter++;
        _pages = _buildPages();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Không force redirect LoginScreen khi Unauthenticated — khách có thể dùng app tự do
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryGoldDark,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.piano), label: 'Pianos'),
          BottomNavigationBarItem(
            icon: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Khám phá'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
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

/// Màn hình Hồ Sơ — hiển thị nút Đăng nhập nếu chưa Auth, hoặc thông tin user nếu đã Auth
class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    // Khách chưa đăng nhập
    if (authState is! AuthAuthenticated) {
      return _buildGuestProfile(context);
    }

    // Đã đăng nhập
    final user = authState.user;
    final isTeacher = user.isTeacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'Hồ sơ giáo viên' : 'Hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User card
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(isTeacher ? 'Giáo viên' : 'Học viên', style: const TextStyle(color: AppTheme.textSecondary)),
              trailing: Chip(
                label: Text(isTeacher ? 'Giáo viên' : 'Học viên', style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: isTeacher ? AppTheme.primaryGold : Colors.blueGrey,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const ListTile(
            leading: Icon(Icons.shopping_bag, color: AppTheme.textPrimary),
            title: Text('Khóa học của tôi'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.history, color: AppTheme.textPrimary),
            title: Text('Lịch sử đơn hàng'),
            trailing: Icon(Icons.chevron_right),
          ),

          if (isTeacher) ...[
            const Divider(height: 40, thickness: 1),
            const Text('Khu vực Giáo viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.upload_file, color: AppTheme.primaryGold),
              title: const Text('Cập nhật Chứng chỉ'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.create, color: AppTheme.primaryGold),
              title: const Text('Quản lý khóa học (CMS)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: AppTheme.primaryGold),
              title: const Text('Thống kê thu nhập'),
              onTap: () {},
            ),
          ],

          const Divider(height: 40),
          Center(
            child: TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, size: 40, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chào mừng đến Xpiano!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để trải nghiệm đầy đủ tính năng',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
