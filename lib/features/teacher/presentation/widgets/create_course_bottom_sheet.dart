import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/media_upload_service.dart';
import '../../../explore/data/models/course_model.dart';
import '../bloc/teacher_course_bloc.dart';
import '../bloc/teacher_course_event.dart';

/// Form BottomSheet Tạo / Chỉnh sửa khóa học có kèm tính năng Upload Media
class CreateCourseBottomSheet extends StatefulWidget {
  final CourseModel? editCourse;
  const CreateCourseBottomSheet({super.key, required this.editCourse});

  @override
  State<CreateCourseBottomSheet> createState() =>
      _CreateCourseBottomSheetState();
}

class _CreateCourseBottomSheetState extends State<CreateCourseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _sessionsCtrl;
  late final TextEditingController _maxStudentsCtrl;
  DateTime? _startDate;
  bool _isOnline = true;

  // Media
  final ImagePicker _picker = ImagePicker();
  File? _selectedCoverImage;
  File? _selectedDemoVideo;
  String? _existingCoverUrl;
  String? _existingDemoVideoUrl;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  String? _errorMessage;
  bool _showDateError = false;

  // Schedule
  final List<Map<String, String>> _scheduleEntries = [];

  @override
  void initState() {
    super.initState();
    final c = widget.editCourse;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _priceCtrl = TextEditingController(text: c?.price.toString() ?? '0');
    _durationCtrl = TextEditingController(
      text: c?.durationWeeks.toString() ?? '4',
    );
    _sessionsCtrl = TextEditingController(
      text: c?.sessionsPerWeek.toString() ?? '2',
    );
    _maxStudentsCtrl = TextEditingController(
      text: c?.maxStudents.toString() ?? '10',
    );
    _isOnline = c?.isOnline ?? true;
    _existingCoverUrl = c?.coverUrl;
    _existingDemoVideoUrl = c?.demoVideoUrl;

    if (c?.startDate != null) {
      _startDate = DateTime.tryParse(c!.startDate!);
    }
    if (c?.schedule != null) {
      for (final s in c!.schedule) {
        _scheduleEntries.add({
          'day_of_week': s['day_of_week']?.toString() ?? '1',
          'time': s['time']?.toString() ?? '09:00',
        });
      }
    }
    if (_scheduleEntries.isEmpty) {
      _scheduleEntries.add({'day_of_week': '1', 'time': '09:00'});
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _sessionsCtrl.dispose();
    _maxStudentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedCoverImage = File(picked.path);
      });
    }
  }

  Future<void> _pickDemoVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedDemoVideo = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _showDateError = false;
    });

    bool isValid = _formKey.currentState!.validate();
    if (_startDate == null) {
      setState(() => _showDateError = true);
      isValid = false;
    }

    if (!isValid) {
      setState(() {
        _errorMessage =
            'Vui lòng điền đầy đủ và kiểm tra lại các thông tin bắt buộc';
      });
      return;
    }

    setState(() => _isUploading = true);
    String? coverUrl = _existingCoverUrl;
    String? videoUrl = _existingDemoVideoUrl;

    try {
      final uploadService = sl<MediaUploadService>();

      if (_selectedCoverImage != null) {
        setState(() => _uploadStatus = 'Đang tải ảnh bìa lên...');
        coverUrl = await uploadService.uploadFile(
          file: _selectedCoverImage!,
          uploadType: 'course_image',
        );
      }

      if (_selectedDemoVideo != null) {
        videoUrl = await uploadService.uploadFile(
          file: _selectedDemoVideo!,
          uploadType: 'course_video',
          onProgress: (p) => setState(() => _uploadProgress = p),
          onStatusChange: (status) => setState(() => _uploadStatus = status),
        );
      } // wait a moment on success
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi upload: $e';
        _isUploading = false;
      });
      return;
    }

    final body = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': int.tryParse(_priceCtrl.text) ?? 0,
      'duration_weeks': int.tryParse(_durationCtrl.text) ?? 4,
      'sessions_per_week': int.tryParse(_sessionsCtrl.text) ?? 2,
      'max_students': int.tryParse(_maxStudentsCtrl.text) ?? 10,
      'start_date': _startDate!.toIso8601String(),
      'is_online': _isOnline,
      'schedule': _scheduleEntries,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (videoUrl != null) 'demo_video_url': videoUrl,
    };

    if (widget.editCourse != null) {
      context.read<TeacherCourseBloc>().add(
        UpdateTeacherCourse(widget.editCourse!.id, body),
      );
    } else {
      context.read<TeacherCourseBloc>().add(CreateTeacherCourse(body));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editCourse != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
          child: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEdit ? 'Chỉnh sửa khóa học' : 'Tạo khóa học mới',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGoldDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    _buildField(
                      _titleCtrl,
                      'Tên khóa học *',
                      validator: _required,
                    ),
                    _buildField(_descCtrl, 'Mô tả', maxLines: 3),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _priceCtrl,
                            'Giá (VNĐ)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            _durationCtrl,
                            'Số tuần',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _sessionsCtrl,
                            'Số buổi/tuần',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            _maxStudentsCtrl,
                            'Tối đa HV',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month,
                        color: AppTheme.primaryGold,
                      ),
                      title: Text(
                        _startDate != null
                            ? 'Bắt đầu: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                            : 'Chọn ngày bắt đầu *',
                        style: TextStyle(
                          color: _startDate != null
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                    ),
                    if (_showDateError)
                      const Padding(
                        padding: EdgeInsets.only(left: 40, bottom: 8),
                        child: Text(
                          'Vui lòng chọn ngày bắt đầu',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    // Media Section
                    const SizedBox(height: 16),
                    const Text(
                      'Ảnh bìa & Video Demo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickCoverImage,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedCoverImage != null
                                  ? Image.file(
                                      _selectedCoverImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : (_existingCoverUrl != null
                                        ? Image.network(
                                            _existingCoverUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image,
                                                color: AppTheme.textSecondary,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Chọn ảnh bìa',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          )),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickDemoVideo,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedDemoVideo != null
                                  ? const Center(
                                      child: Icon(
                                        Icons.video_file,
                                        size: 40,
                                        color: AppTheme.primaryGold,
                                      ),
                                    )
                                  : (_existingDemoVideoUrl != null
                                        ? const Center(
                                            child: Icon(
                                              Icons.ondemand_video,
                                              size: 40,
                                              color: AppTheme.primaryGoldDark,
                                            ),
                                          )
                                        : const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.video_call,
                                                color: AppTheme.textSecondary,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Chọn video',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          )),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Lịch học (thứ + giờ)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._scheduleEntries.asMap().entries.map((e) {
                      final idx = e.key;
                      final entry = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: entry['day_of_week'],
                                decoration: _inputDeco('Thứ'),
                                items: const [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('T2'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('T3'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3',
                                    child: Text('T4'),
                                  ),
                                  DropdownMenuItem(
                                    value: '4',
                                    child: Text('T5'),
                                  ),
                                  DropdownMenuItem(
                                    value: '5',
                                    child: Text('T6'),
                                  ),
                                  DropdownMenuItem(
                                    value: '6',
                                    child: Text('T7'),
                                  ),
                                  DropdownMenuItem(
                                    value: '0',
                                    child: Text('CN'),
                                  ),
                                ],
                                onChanged: (v) => setState(
                                  () =>
                                      _scheduleEntries[idx]['day_of_week'] = v!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: entry['time'],
                                decoration: _inputDeco('Giờ (HH:mm)'),
                                onChanged: (v) =>
                                    _scheduleEntries[idx]['time'] = v,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: _scheduleEntries.length > 1
                                  ? () => setState(
                                      () => _scheduleEntries.removeAt(idx),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => _scheduleEntries.add({
                            'day_of_week': '1',
                            'time': '09:00',
                          }),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm lịch'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryGold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    if (_isUploading)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _uploadProgress,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _uploadStatus,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'CẬP NHẬT' : 'TẠO KHÓA HỌC',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _inputDeco(label),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
    filled: true,
    fillColor: AppTheme.bgCreamDarker.withValues(alpha: 0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.dividerColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.dividerColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;
}
