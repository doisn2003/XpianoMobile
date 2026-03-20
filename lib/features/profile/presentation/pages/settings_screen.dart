import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'Cài đặt tài khoản',
                    subtitle: 'Thông tin cá nhân, bảo mật',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt hệ thống',
                    subtitle: 'Ngôn ngữ, giao diện ứng dụng',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.volume_up_outlined,
                    title: 'Cài đặt âm thanh',
                    subtitle: 'Âm lượng, thiết bị MIDI',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Cài đặt thông báo',
                    subtitle: 'Thông báo đẩy, nhắc nhở học tập',
                    onTap: () {},
                  ),
                  const Divider(height: 32, indent: 16, endIndent: 16),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'Về Xpiano',
                    subtitle: 'Phiên bản 1.0.0',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Hỗ trợ & Góp ý',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đăng xuất',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryGold, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
