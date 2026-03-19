import 'package:flutter/material.dart';
import '../../../../core/widgets/user_avatar_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'active_rentals_screen.dart';
import 'affiliate_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import '../../my_courses/presentation/pages/my_courses_screen.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import 'wallet_screen.dart';
import '../../../teacher/presentation/bloc/teacher_profile_bloc.dart';
import '../../../teacher/presentation/bloc/teacher_profile_event.dart';
import '../../../teacher/presentation/bloc/teacher_profile_state.dart';
import '../../../teacher/presentation/pages/teacher_certificate_screen.dart';
import '../../../teacher/presentation/pages/course_management_screen.dart';
import '../../../teacher/presentation/pages/income_stats_screen.dart';
import '../../../feed/presentation/pages/saved_posts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TeacherProfileBloc? _teacherProfileBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ khởi tạo 1 lần cho teacher: cache verification_status
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated &&
        authState.user.isTeacher &&
        _teacherProfileBloc == null) {
      _teacherProfileBloc = TeacherProfileBloc(repository: sl())
        ..add(LoadTeacherProfile());
    }
  }

  @override
  void dispose() {
    _teacherProfileBloc?.close();
    super.dispose();
  }

  /// Điều hướng đến tính năng giáo viên — kiểm tra từ cache.
  void _navigateTeacherFeature(
      BuildContext context, Widget approvedScreen) {
    final state = _teacherProfileBloc?.state;

    if (state is TeacherProfileNotFound) {
      // Chưa gửi hồ sơ bao giờ
      _showTeacherGateDialog(
        context,
        title: 'Đăng ký hồ sơ giáo viên',
        message:
            'Bạn cần đăng ký và được phê duyệt hồ sơ trước khi sử dụng tính năng này.',
        buttonText: 'Đăng ký ngay',
        destination: const TeacherCertificateScreen(),
      );
      return;
    }

    if (state is TeacherProfileLoaded) {
      final profile = state.profile;
      if (profile.isApproved) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => approvedScreen));
        return;
      }
      // pending hoặc rejected
      final isPending = profile.isPending;
      _showTeacherGateDialog(
        context,
        title: isPending ? 'Hồ sơ đang chờ duyệt' : 'Hồ sơ bị từ chối',
        message: isPending
            ? 'Hồ sơ của bạn đang được admin xem xét. Vui lòng đợi hoặc cập nhật thêm thông tin.'
            : 'Hồ sơ của bạn đã bị từ chối. Vui lòng cập nhật và gửi lại.',
        buttonText: 'Xem hồ sơ',
        destination: const TeacherCertificateScreen(),
      );
      return;
    }

    // Đang loading hoặc error — navigate thẳng, screen tự hiển thị
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => approvedScreen));
  }

  void _showTeacherGateDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required Widget destination,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGoldDark)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => destination));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

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
        title: Text('Hồ sơ cá nhân'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletBloc>().add(LoadWallet());
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // User card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.dividerColor, width: 1.0),
              ),
              child: ListTile(
                leading: UserAvatarWidget(
                  fullName: user.fullName,
                  avatarUrl: user.avatar,
                  role: isTeacher ? 'teacher' : 'user',
                  radius: 24,
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
              icon: Icons.school,
              title: 'Khóa học của tôi',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCoursesScreen()));
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.favorite_border,
              title: 'Danh sách đàn yêu thích',
              //iconColor: Colors.redAccent,
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
              icon: Icons.bookmark_border,
              title: 'Bài viết đã lưu',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPostsScreen()));
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.monetization_on,
              title: 'Affiliate',
              //iconColor: Colors.blueAccent,
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
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherCertificateScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.create, color: AppTheme.primaryGold),
                title: const Text('Quản lý khóa học (CMS)'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => _navigateTeacherFeature(context, const CourseManagementScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: AppTheme.primaryGold),
                title: const Text('Thống kê thu nhập'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => _navigateTeacherFeature(context, const IncomeStatsScreen()),
              ),
            ],
          ],
        ),
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
    return BlocProvider.value(
      value: sl<WalletBloc>(),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletInitial) {
            context.read<WalletBloc>().add(LoadWallet());
          }

          final bool isVisible = state.isBalanceVisible;
          final String balanceText = state is WalletLoaded
              ? (isVisible
                  ? NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ', decimalDigits: 0).format(state.wallet.availableBalance)
                  : '*** ***')
              : (state is WalletLoading ? 'Đang tải...' : '*** ***');

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
                      decoration: const BoxDecoration(
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
                          Row(
                            children: [
                              const Text('Ví của tôi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  context.read<WalletBloc>().add(ToggleBalanceVisibility());
                                },
                                child: Icon(
                                  isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Chỗ này hiển thị số dư:
                          Text('Số dư: $balanceText', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Text('Quản lý ví', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
