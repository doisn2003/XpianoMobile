import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/teacher_profile_model.dart';
import '../bloc/teacher_profile_bloc.dart';
import '../bloc/teacher_profile_event.dart';
import '../bloc/teacher_profile_state.dart';

/// Màn hình "Cập nhật chứng chỉ / Hồ sơ giáo viên".
///
/// - Nếu profile chưa tồn tại (pending mới): form đăng ký đầy đủ.
/// - Nếu profile rejected/approved: cho cập nhật / bổ sung.
class TeacherCertificateScreen extends StatelessWidget {
  const TeacherCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TeacherProfileBloc(repository: sl())..add(LoadTeacherProfile()),
      child: const _TeacherCertificateBody(),
    );
  }
}

class _TeacherCertificateBody extends StatelessWidget {
  const _TeacherCertificateBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ giáo viên')),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<TeacherProfileBloc, TeacherProfileState>(
        listener: (context, state) {
          if (state is TeacherProfileSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Gửi hồ sơ thành công! Vui lòng đợi admin phê duyệt.'),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TeacherProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TeacherProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeacherProfileNotFound) {
            return _TeacherProfileForm(initialProfile: null);
          }

          if (state is TeacherProfileLoaded) {
            return _buildProfileStatusView(context, state.profile);
          }

          if (state is TeacherProfileSubmitted) {
            return _buildProfileStatusView(context, state.profile);
          }

          if (state is TeacherProfileSubmitting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang gửi hồ sơ...',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          if (state is TeacherProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48,
                      color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TeacherProfileBloc>()
                        .add(LoadTeacherProfile()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      )),
    );
  }

  Widget _buildProfileStatusView(
      BuildContext context, TeacherProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusBanner(profile),
        const SizedBox(height: 20),
        _TeacherProfileForm(initialProfile: profile),
      ],
    );
  }

  Widget _buildStatusBanner(TeacherProfile profile) {
    Color bgColor;
    Color fgColor;
    IconData icon;
    String title;
    String subtitle;

    if (profile.isApproved) {
      bgColor = const Color(0xFFE8F5E9);
      fgColor = const Color(0xFF2E7D32);
      icon = Icons.verified;
      title = 'Hồ sơ đã được phê duyệt ✓';
      subtitle =
          'Bạn có thể cập nhật thêm thông tin chứng chỉ bên dưới nếu cần.';
    } else if (profile.isRejected) {
      bgColor = const Color(0xFFFFEBEE);
      fgColor = const Color(0xFFC62828);
      icon = Icons.cancel;
      title = 'Hồ sơ bị từ chối';
      subtitle = profile.rejectedReason ?? 'Vui lòng cập nhật và gửi lại.';
    } else {
      bgColor = const Color(0xFFFFF8E1);
      fgColor = AppTheme.primaryGoldDark;
      icon = Icons.hourglass_top;
      title = 'Hồ sơ đang chờ duyệt';
      subtitle = 'Admin sẽ xét duyệt hồ sơ của bạn sớm nhất.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: fgColor, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FORM ĐĂNG KÝ / CẬP NHẬT HỒ SƠ GIÁO VIÊN
// ============================================================

class _TeacherProfileForm extends StatefulWidget {
  final TeacherProfile? initialProfile;

  const _TeacherProfileForm({this.initialProfile});

  @override
  State<_TeacherProfileForm> createState() => _TeacherProfileFormState();
}

class _TeacherProfileFormState extends State<_TeacherProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _yearsCtrl;
  late final TextEditingController _specializationsCtrl;
  late final TextEditingController _priceOnlineCtrl;
  late final TextEditingController _priceOfflineCtrl;
  late final TextEditingController _certsDescCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _bankAccountCtrl;
  late final TextEditingController _accountHolderCtrl;

  bool _teachOnline = true;
  bool _teachOffline = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _fullNameCtrl = TextEditingController(text: p?.fullName ?? '');
    _bioCtrl = TextEditingController(text: p?.bio ?? '');
    _yearsCtrl =
        TextEditingController(text: p?.yearsExperience.toString() ?? '');
    _specializationsCtrl =
        TextEditingController(text: p?.specializations.join(', ') ?? '');
    _priceOnlineCtrl =
        TextEditingController(text: p?.priceOnline.toString() ?? '0');
    _priceOfflineCtrl =
        TextEditingController(text: p?.priceOffline.toString() ?? '0');
    _certsDescCtrl =
        TextEditingController(text: p?.certificatesDescription ?? '');
    _idNumberCtrl = TextEditingController(text: p?.idNumber ?? '');
    _bankNameCtrl = TextEditingController(text: p?.bankName ?? '');
    _bankAccountCtrl = TextEditingController(text: p?.bankAccount ?? '');
    _accountHolderCtrl = TextEditingController(text: p?.accountHolder ?? '');
    _teachOnline = p?.teachOnline ?? true;
    _teachOffline = p?.teachOffline ?? false;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _yearsCtrl.dispose();
    _specializationsCtrl.dispose();
    _priceOnlineCtrl.dispose();
    _priceOfflineCtrl.dispose();
    _certsDescCtrl.dispose();
    _idNumberCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccountCtrl.dispose();
    _accountHolderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final specs = _specializationsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final body = <String, dynamic>{
      'full_name': _fullNameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'years_experience': int.tryParse(_yearsCtrl.text) ?? 0,
      'specializations': specs,
      'teach_online': _teachOnline,
      'teach_offline': _teachOffline,
      'price_online': int.tryParse(_priceOnlineCtrl.text) ?? 0,
      'price_offline': int.tryParse(_priceOfflineCtrl.text) ?? 0,
      'certificates_description': _certsDescCtrl.text.trim(),
      if (_idNumberCtrl.text.trim().isNotEmpty)
        'id_number': _idNumberCtrl.text.trim(),
      if (_bankNameCtrl.text.trim().isNotEmpty)
        'bank_name': _bankNameCtrl.text.trim(),
      if (_bankAccountCtrl.text.trim().isNotEmpty)
        'bank_account': _bankAccountCtrl.text.trim(),
      if (_accountHolderCtrl.text.trim().isNotEmpty)
        'account_holder': _accountHolderCtrl.text.trim(),
    };

    context.read<TeacherProfileBloc>().add(SubmitTeacherProfile(body));
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.initialProfile == null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNew) ...[
            const Text(
              'Đăng ký hồ sơ Giáo viên Xpiano',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGoldDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Điền đầy đủ thông tin bên dưới và gửi để admin xét duyệt.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],

          _SectionTitle('Thông tin cơ bản'),
          const SizedBox(height: 8),
          _buildTextField(_fullNameCtrl, 'Họ và tên *', validator: _required),
          _buildTextField(_bioCtrl, 'Giới thiệu bản thân', maxLines: 3),
          _buildTextField(_yearsCtrl, 'Số năm kinh nghiệm *',
              keyboardType: TextInputType.number, validator: _required),
          _buildTextField(
              _specializationsCtrl, 'Chuyên môn * (cách nhau bằng dấu phẩy)',
              validator: _required),

          const SizedBox(height: 16),
          _SectionTitle('Hình thức giảng dạy & Học phí'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: _teachOnline,
                  onChanged: (v) => setState(() => _teachOnline = v ?? false),
                  title: const Text('Online', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryGold,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  value: _teachOffline,
                  onChanged: (v) => setState(() => _teachOffline = v ?? false),
                  title: const Text('Offline', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryGold,
                ),
              ),
            ],
          ),
          _buildTextField(_priceOnlineCtrl, 'Giá dạy Online (VNĐ/buổi)',
              keyboardType: TextInputType.number),
          _buildTextField(_priceOfflineCtrl, 'Giá dạy Offline (VNĐ/buổi)',
              keyboardType: TextInputType.number),

          const SizedBox(height: 16),
          _SectionTitle('Chứng chỉ / Kinh nghiệm'),
          const SizedBox(height: 8),
          _buildTextField(
              _certsDescCtrl, 'Mô tả chứng chỉ, bằng cấp, kinh nghiệm',
              maxLines: 4),

          const SizedBox(height: 16),
          _SectionTitle('Thông tin cá nhân (bắt buộc cho xác minh)'),
          const SizedBox(height: 8),
          _buildTextField(_idNumberCtrl, 'Số CMND / CCCD'),
          _buildTextField(_bankNameCtrl, 'Tên ngân hàng'),
          _buildTextField(_bankAccountCtrl, 'Số tài khoản'),
          _buildTextField(_accountHolderCtrl, 'Chủ tài khoản'),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isNew ? 'GỬI HỒ SƠ XÉT DUYỆT' : 'CẬP NHẬT HỒ SƠ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          filled: true,
          fillColor: AppTheme.bgCreamDarker.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.dividerColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.dividerColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primaryGold, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
