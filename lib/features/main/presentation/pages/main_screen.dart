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
import '../../../explore/presentation/pages/explore_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/bloc/wallet_bloc.dart';
import '../../../profile/presentation/bloc/wallet_event.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../../injection_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Static callback để banner "Xem ngay" có thể chuyển Home + refresh từ bất cứ đâu
  static _MainScreenState? _instance;
  static void switchToHomeAndRefresh() {
    _instance?._switchToHomeAndRefresh();
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    MainScreen._instance = this;
  }

  @override
  void dispose() {
    if (MainScreen._instance == this) {
      MainScreen._instance = null;
    }
    super.dispose();
  }

  List<Widget> _buildPages() => [
    FeedScreen(
      key: ValueKey('feed_$_refreshCounter'),
      isTabActive: _currentIndex == 0,
    ),
    PianoListScreen(key: ValueKey('piano_$_refreshCounter')),
    const SizedBox(), // Nút cộng — không render
    ExploreScreen(key: ValueKey('explore_$_refreshCounter')),
    ProfileScreen(key: ValueKey('profile_$_refreshCounter')),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showUploadOptions();
    } else if (index == _currentIndex) {
      // Tap lại tab hiện tại → refresh page
      setState(() {
        _refreshCounter++;
      });
      // Explicitly refresh profile data if it's the profile tab
      if (index == 4) {
        sl<WalletBloc>().add(LoadWallet());
      }
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }

  /// Chuyển về tab Home + refresh feed (gọi từ banner "Xem ngay")
  void _switchToHomeAndRefresh() {
    setState(() {
      _currentIndex = 0;
      _refreshCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Không force redirect LoginScreen khi Unauthenticated — khách có thể dùng app tự do
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildPages(),
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
          const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Khám Phá'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ Sơ'),
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

