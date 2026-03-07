import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../main/presentation/pages/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTeacherTab = false; // true = Giáo viên, false = Khách/Học viên
  bool _agreedToTerms = false;

  void _register() {
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final role = _isTeacherTab ? 'teacher' : 'user';

    if (name.isEmpty || dob.isEmpty || email.isEmpty || otp.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu nhập lại không khớp')));
      return;
    }

    context.read<AuthBloc>().add(AuthRegisterRequested(
      email: email,
      otp: otp,
      password: password,
      fullName: name,
      phone: '',
      role: role,
      dob: dob,
    ));
  }

  void _sendOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Email để nhận mã')));
      return;
    }
    context.read<AuthBloc>().add(AuthSendOtpRequested(email));
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFB901),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFFFB901);
    const Color darkBackground = Color(0xFF141414);
    const Color inputBackground = Color(0xFF1E1E1E);
    const Color borderColor = Color(0xFF333333);

    return Scaffold(
      backgroundColor: darkBackground,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi mã OTP đến email')));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthAuthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Đăng ký tài khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryYellow,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tạo tài khoản để tham gia cộng đồng Xpiano',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Tab Selector
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: inputBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTeacherTab = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isTeacherTab ? primaryYellow : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Khách/Học viên',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: !_isTeacherTab ? Colors.black : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTeacherTab = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isTeacherTab ? primaryYellow : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Giáo viên',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _isTeacherTab ? Colors.black : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Inputs
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Họ và tên',
                  iconData: Icons.person_outline,
                  inputBgColor: inputBackground,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _dobController,
                  hintText: 'dd/mm/yyyy (Ngày sinh)',
                  iconData: Icons.calendar_today_outlined,
                  inputBgColor: inputBackground,
                  borderColor: borderColor,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    DateTextFormatter(),
                  ],
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range, color: primaryYellow, size: 20),
                    onPressed: _selectDate,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  iconData: Icons.email_outlined,
                  inputBgColor: inputBackground,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 16),
                
                // Row with Input and Button
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _otpController,
                        hintText: 'Mã xác thực',
                        iconData: Icons.verified_user_outlined,
                        inputBgColor: inputBackground,
                        borderColor: borderColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryYellow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          child: state is AuthLoading 
                             ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                             : const Text(
                                'Gửi mã', 
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Mật khẩu',
                  iconData: Icons.lock_outline,
                  inputBgColor: inputBackground,
                  borderColor: borderColor,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Nhập lại mật khẩu',
                  iconData: Icons.lock_outline,
                  inputBgColor: inputBackground,
                  borderColor: borderColor,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
                const SizedBox(height: 16),

                // Terms Checkbox
                Row(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: Colors.grey,
                      ),
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: primaryYellow,
                        checkColor: Colors.black,
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tôi đồng ý với Điều khoản & Chính sách',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nút Đăng ký
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading || !_agreedToTerms ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      disabledBackgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: state is AuthLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text(
                            'ĐĂNG KÝ', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Đã có tài khoản? ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        // Trở về Login
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(color: primaryYellow, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData iconData,
    required Color inputBgColor,
    required Color borderColor,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: inputBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(iconData, color: Colors.grey, size: 20),
          suffixIcon: suffixIcon ?? (isPassword 
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String oldText = oldValue.text;
    final String newText = newValue.text;
    
    // Nếu đang xóa văn bản, cho phép thực hiện mà không can thiệp
    if (newText.length < oldText.length) {
      return newValue;
    }

    String text = newText;
    int selectionOffset = newValue.selection.end;
    
    // Tự động chèn dấu '/' ở vị trí thứ 2 và thứ 5 nếu vừa gõ đến đó
    if (text.length == 2 || text.length == 5) {
      if (!text.endsWith('/')) {
        text += '/';
        selectionOffset++;
      }
    }
    
    // Giới hạn 10 ký tự (dd/mm/yyyy)
    if (text.length > 10) {
      text = text.substring(0, 10);
      selectionOffset = 10;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
