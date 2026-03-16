import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'active_rentals_screen.dart';
import 'affiliate_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'my_courses_screen.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.dividerColor, width: 1.0),
            ),
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
              trailing: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Chỉnh sửa'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Wallet Card widget call
          const _WalletSummaryCard(),

          const SizedBox(height: 20),

          // Menu List
          _buildMenuItem(
            context,
            icon: Icons.shopping_bag,
            title: 'Khóa học của tôi',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCoursesScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite,
            title: 'Danh sách đàn yêu thích',
            iconColor: Colors.redAccent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Lịch sử đơn hàng',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.piano,
            title: 'Đàn piano đang thuê',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRentalsScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.share,
            title: 'Affiliate',
            iconColor: Colors.blueAccent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AffiliateScreen()));
            },
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
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, Color iconColor = AppTheme.textPrimary, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
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
                'Đăng nhập để trải nghiệm đầy đủ tính năng. Cùng Xpiano xây dựng cộng đồng!',
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

class _WalletSummaryCard extends StatelessWidget {
  const _WalletSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.primaryGoldLight.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.primaryGold, width: 1.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ví của tôi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Xem số dư và quản lý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
            ],
          ),
        ),
      ),
    );
  }
}
