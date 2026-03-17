import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/edit_profile_bloc.dart';
import '../bloc/edit_profile_event.dart';
import '../bloc/edit_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _schoolController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late DateTime? _selectedDate;
  File? _avatarFile;
  
  final List<String> _hobbies = [];
  final List<String> _instruments = [];
  
  final TextEditingController _hobbyInputController = TextEditingController();
  final TextEditingController _instrumentInputController = TextEditingController();

  final FocusNode _bioFocusNode = FocusNode();
  bool _isBioFocused = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio);
    _occupationController = TextEditingController(text: widget.user.occupation);
    _schoolController = TextEditingController(text: widget.user.school);
    _locationController = TextEditingController(text: widget.user.location);
    _phoneController = TextEditingController(text: widget.user.phone);
    
    if (widget.user.dateOfBirth != null) {
      try {
        _selectedDate = DateTime.parse(widget.user.dateOfBirth!);
      } catch (_) {
        _selectedDate = null;
      }
    } else {
      _selectedDate = null;
    }
    
    if (widget.user.hobbies != null) _hobbies.addAll(widget.user.hobbies!);
    if (widget.user.instruments != null) _instruments.addAll(widget.user.instruments!);

    _bioFocusNode.addListener(() {
      setState(() {
        _isBioFocused = _bioFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _schoolController.dispose();
    _locationController.dispose();
    _hobbyInputController.dispose();
    _instrumentInputController.dispose();
    _phoneController.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'full_name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'school': _schoolController.text.trim(),
        'location': _locationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'date_of_birth': _selectedDate?.toIso8601String().split('T')[0],
        'hobbies': _hobbies,
        'instruments': _instruments,
      };
      
      context.read<EditProfileBloc>().add(EditProfileSubmit(profileData, avatarFile: _avatarFile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EditProfileBloc>(),
      child: BlocListener<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Cập nhật AuthBloc để toàn app nhận User mới
            context.read<AuthBloc>().add(AuthUserChanged(state.user));
            if (state.message.contains('thông tin')) {
                Navigator.pop(context);
            }
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chỉnh sửa hồ sơ'),
                actions: [
                  TextButton(
                    onPressed: () => _submitForm(context),
                    child: const Text('Lưu', style: TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Avatar ---
                      Center(
                        child: Stack(
                          children: [
                            BlocBuilder<EditProfileBloc, EditProfileState>(
                              builder: (context, state) {
                                String? avatarUrl = widget.user.avatar;
                                if (state is EditProfileSuccess) {
                                  avatarUrl = state.user.avatar;
                                }
                                
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                                  backgroundImage: _avatarFile != null 
                                    ? FileImage(_avatarFile!) as ImageProvider
                                    : (avatarUrl != null ? NetworkImage(avatarUrl) : null),
                                  child: (_avatarFile == null && avatarUrl == null)
                                    ? Text(widget.user.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: AppTheme.primaryGoldDark))
                                    : null,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _pickImage(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            BlocBuilder<EditProfileBloc, EditProfileState>(
                              builder: (context, state) {
                                if (state is EditProfileUploadingAvatar) {
                                  return Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                                      child: Center(
                                        child: CircularProgressIndicator(value: state.progress, color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // --- Bio ---
                      _buildSectionTitle('Giới thiệu ngắn (Tiểu sử)'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bioController,
                        focusNode: _bioFocusNode,
                        maxLines: _isBioFocused ? 3 : 1,
                        maxLength: 100,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('', Icons.info_outline).copyWith(
                          labelText: 'Nhập một vài lời về bản thân...',
                          alignLabelWithHint: false,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value != null && value.split(RegExp(r'\s+')).length > 30) {
                            return 'Tiểu sử tối đa 30 chữ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // --- Full Name ---
                      _buildSectionTitle('Họ và tên'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('Nhập họ tên', Icons.person),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ tên';
                          if (value.length > 50) return 'Tên quá dài (tối đa 50 ký tự)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // --- Phone Number ---
                      _buildSectionTitle('Số điện thoại'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 14),
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration('Nhập số điện thoại', Icons.phone),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                          // Basic regex for VN phone number
                          if (!RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})\b$').hasMatch(value.trim())) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- Date of Birth ---
                      _buildSectionTitle('Ngày sinh'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.dividerColor),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppTheme.textSecondary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null ? 'Chọn ngày sinh' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Professional & Location ---
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Nghề nghiệp'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _occupationController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _buildInputDecoration('Ví dụ: Giáo viên', Icons.work_outline, isCompact: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Trường học'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _schoolController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _buildInputDecoration('Ví dụ: Bách Khoa', Icons.school_outlined, isCompact: true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      _buildSectionTitle('Nơi ở'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('Ví dụ: Hà Nội', Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 20),

                      // --- Hobbies ---
                      _buildSectionTitle('Sở thích'),
                      const SizedBox(height: 8),
                      _buildTagInput(
                        controller: _hobbyInputController,
                        hint: 'Thêm sở thích...',
                        onAdd: (val) {
                          if (val.isNotEmpty && !_hobbies.contains(val)) {
                            setState(() => _hobbies.add(val));
                            _hobbyInputController.clear();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _hobbies.map((h) => _buildTag(h, () => setState(() => _hobbies.remove(h)))).toList(),
                      ),
                      const SizedBox(height: 20),

                      // --- Instruments ---
                      _buildSectionTitle('Nhạc cụ của tôi'),
                      const SizedBox(height: 8),
                      _buildTagInput(
                        controller: _instrumentInputController,
                        hint: 'Thêm nhạc cụ...',
                        onAdd: (val) {
                          if (val.isNotEmpty && !_instruments.contains(val)) {
                            setState(() => _instruments.add(val));
                            _instrumentInputController.clear();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _instruments.map((i) => _buildTag(i, () => setState(() => _instruments.remove(i)))).toList(),
                      ),
                      const SizedBox(height: 40),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocBuilder<EditProfileBloc, EditProfileState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is EditProfileLoading ? null : () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: state is EditProfileLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Lưu thông tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, {bool isCompact = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 8.0 : 12.0),
        child: Icon(icon, color: AppTheme.textSecondary, size: isCompact ? 18 : 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: isCompact ? 11 : 12),
      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: AppTheme.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5)),
    );
  }

  Widget _buildTagInput({required TextEditingController controller, required String hint, required Function(String) onAdd}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: _buildInputDecoration(hint, Icons.add_circle_outline),
            onSubmitted: (val) => onAdd(val.trim()),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => onAdd(controller.text.trim()),
          icon: const Icon(Icons.add_circle, color: AppTheme.primaryGold, size: 32),
        ),
      ],
    );
  }

  Widget _buildTag(String text, VoidCallback onDelete) {
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textGold, fontWeight: FontWeight.w500)),
      backgroundColor: AppTheme.primaryGoldLight.withOpacity(0.3),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.textGold),
      onDeleted: onDelete,
    );
  }
}
