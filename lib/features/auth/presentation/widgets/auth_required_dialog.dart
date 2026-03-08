import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../pages/register_screen.dart';

/// Cửa sổ popup Đăng nhập tái sử dụng.
/// Chiếm ~75% màn hình, chỉ chứa form Login + placeholder OTP/Google.
/// Link "Đăng ký" sẽ navigate sang RegisterScreen (page đầy đủ).
///
/// Sử dụng:
/// ```dart
/// final loggedIn = await AuthRequiredDialog.show(context);
/// if (loggedIn) { /* Đã đăng nhập thành công */ }
/// ```
class AuthRequiredDialog extends StatefulWidget {
  const AuthRequiredDialog({super.key});

  /// Hiển thị popup Login. Trả về `true` nếu đăng nhập thành công.
  static Future<bool> show(BuildContext context) async {
    // Lấy AuthBloc toàn cục từ context thay vì tạo mới
    final authBloc = context.read<AuthBloc>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const AuthRequiredDialog(),
      ),
    );
    return result ?? false;
  }

  @override
  State<AuthRequiredDialog> createState() => _AuthRequiredDialogState();
}

class _AuthRequiredDialogState extends State<AuthRequiredDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isTeacherTab = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _isTeacherTab ? 'teacher' : 'user';

    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthBloc>().add(AuthPasswordLoginRequested(email, password, role));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu')),
      );
    }
  }

  void _goToRegister() {
    Navigator.pop(context, false); // Đóng popup
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom; // Chiều cao bàn phím
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom; // Android navbar height
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pop(context, true);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar & Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Scrollable content — trôi lên khi bàn phím mở
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInsets + bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Đăng nhập để tiếp tục',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vui lòng đăng nhập để sử dụng tính năng này',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Tab selector (Khách/Học viên | Giáo viên)
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.bgCreamDarker,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildTab('Khách/Học viên', !_isTeacherTab, () => setState(() => _isTeacherTab = false)),
                          _buildTab('Giáo viên', _isTeacherTab, () => setState(() => _isTeacherTab = true)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    _buildInputField(
                      controller: _emailController,
                      hint: 'Số điện thoại / Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    _buildInputField(
                      controller: _passwordController,
                      hint: 'Mật khẩu',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    // Login button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGold,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'ĐĂNG NHẬP',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ─── Divider "hoặc đăng nhập bằng" ───
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.dividerColor, thickness: 1)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('hoặc', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ),
                        Expanded(child: Divider(color: AppTheme.dividerColor, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // OTP login button (Coming soon)
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: null, // Coming soon
                        icon: const Icon(Icons.sms_outlined, size: 20),
                        label: const Text('Đăng nhập bằng OTP', style: TextStyle(fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.dividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Google login button (Coming soon)
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: null, // Coming soon
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Đăng nhập bằng Google', style: TextStyle(fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.dividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chưa có tài khoản? ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: _goToRegister,
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
