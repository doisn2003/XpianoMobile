import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../explore/data/models/course_model.dart';
import '../bloc/teacher_course_bloc.dart';
import '../bloc/teacher_course_event.dart';
import '../bloc/teacher_course_state.dart';
import 'package:intl/intl.dart';

/// Màn hình Quản lý khóa học (CMS) dành cho giáo viên.
class CourseManagementScreen extends StatelessWidget {
  const CourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TeacherCourseBloc(repository: sl())..add(LoadTeacherCourses()),
      child: const _CourseManagementBody(),
    );
  }
}

class _CourseManagementBody extends StatelessWidget {
  const _CourseManagementBody();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý khóa học'),
          bottom: TabBar(
            labelColor: AppTheme.primaryGoldDark,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryGold,
            tabs: const [
              Tab(text: 'Khóa học'),
              Tab(text: 'Lớp học'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CoursesTab(),
            _ClassroomComingSoon(),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// TAB 1: KHÓA HỌC
// ==============================================================

class _CoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherCourseBloc, TeacherCourseState>(
      listener: (context, state) {
        if (state is TeacherCourseActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is TeacherCourseError) {
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
        if (state is TeacherCourseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<CourseModel> courses = [];
        if (state is TeacherCourseLoaded) courses = state.courses;
        if (state is TeacherCourseActionLoading) courses = state.courses;
        if (state is TeacherCourseActionSuccess) courses = state.courses;

        return Stack(
          children: [
            if (courses.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    const Text('Chưa có khóa học nào',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Nhấn nút + để tạo khóa học đầu tiên',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TeacherCourseBloc>()
                      .add(LoadTeacherCourses());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _CourseCard(course: courses[index]),
                ),
              ),

            // FAB
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                onPressed: () => _showCreateCourseDialog(context),
                child: const Icon(Icons.add),
              ),
            ),

            // Loading overlay for actions
            if (state is TeacherCourseActionLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  void _showCreateCourseDialog(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: parentContext.read<TeacherCourseBloc>(),
        child: _CreateCourseSheet(),
      ),
    );
  }
}

// ==============================================================
// COURSE CARD
// ==============================================================

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final isDraft = course.status == 'draft';
    final priceFmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'VNĐ', decimalDigits: 0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDraft
              ? AppTheme.primaryGold.withOpacity(0.5)
              : AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: course.status),
              ],
            ),
            const SizedBox(height: 8),
            // Info row
            Row(
              children: [
                _InfoTag(
                    icon: Icons.calendar_today,
                    text: '${course.durationWeeks} tuần'),
                const SizedBox(width: 12),
                _InfoTag(
                    icon: Icons.people,
                    text: 'Tối đa ${course.maxStudents} HV'),
                const SizedBox(width: 12),
                _InfoTag(
                    icon: Icons.monetization_on,
                    text: priceFmt.format(course.price)),
              ],
            ),
            const SizedBox(height: 10),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDraft) ...[
                  TextButton.icon(
                    onPressed: () =>
                        _showEditCourseDialog(context, course),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Sửa'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGoldDark),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: () => _confirmPublish(context, course.id),
                    icon: const Icon(Icons.publish, size: 16),
                    label: const Text('Xuất bản'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPublish(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xuất bản khóa học?'),
        content: const Text(
            'Sau khi xuất bản, các buổi học sẽ được tạo tự động và không thể chỉnh sửa khóa học nữa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TeacherCourseBloc>()
                  .add(PublishTeacherCourse(courseId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xuất bản'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(BuildContext parentContext, CourseModel course) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: parentContext.read<TeacherCourseBloc>(),
        child: _CreateCourseSheet(editCourse: course),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'published':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'Đã xuất bản';
        break;
      case 'draft':
        bg = const Color(0xFFFFF8E1);
        fg = AppTheme.primaryGoldDark;
        label = 'Bản nháp';
        break;
      default:
        bg = AppTheme.bgCreamDarker;
        fg = AppTheme.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ==============================================================
// FORM TẠO / CHỈNH SỬA KHÓA HỌC (Bottom Sheet)
// ==============================================================

class _CreateCourseSheet extends StatefulWidget {
  final CourseModel? editCourse;
  const _CreateCourseSheet({this.editCourse});

  @override
  State<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends State<_CreateCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _sessionsCtrl;
  late final TextEditingController _maxStudentsCtrl;
  DateTime? _startDate;
  bool _isOnline = true;

  // Schedule - simplified: day_of_week + time entries
  final List<Map<String, String>> _scheduleEntries = [];

  @override
  void initState() {
    super.initState();
    final c = widget.editCourse;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _priceCtrl = TextEditingController(text: c?.price.toString() ?? '0');
    _durationCtrl =
        TextEditingController(text: c?.durationWeeks.toString() ?? '4');
    _sessionsCtrl =
        TextEditingController(text: c?.sessionsPerWeek.toString() ?? '2');
    _maxStudentsCtrl =
        TextEditingController(text: c?.maxStudents.toString() ?? '10');
    _isOnline = c?.isOnline ?? true;
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu')),
      );
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
    };

    if (widget.editCourse != null) {
      context.read<TeacherCourseBloc>().add(
            UpdateTeacherCourse(widget.editCourse!.id, body),
          );
    } else {
      context.read<TeacherCourseBloc>().add(CreateTeacherCourse(body));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editCourse != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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
                    color: AppTheme.primaryGoldDark),
              ),
              const SizedBox(height: 16),

              _buildField(_titleCtrl, 'Tên khóa học *',
                  validator: _required),
              _buildField(_descCtrl, 'Mô tả', maxLines: 3),
              Row(
                children: [
                  Expanded(
                    child: _buildField(_priceCtrl, 'Giá (VNĐ)',
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(_durationCtrl, 'Số tuần',
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(_sessionsCtrl, 'Buổi/tuần',
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(_maxStudentsCtrl, 'Tối đa HV',
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),

              // Start date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.calendar_month, color: AppTheme.primaryGold),
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
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),

              // Schedule entries
              const SizedBox(height: 8),
              const Text('Lịch học (thứ + giờ)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
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
                            DropdownMenuItem(value: '1', child: Text('T2')),
                            DropdownMenuItem(value: '2', child: Text('T3')),
                            DropdownMenuItem(value: '3', child: Text('T4')),
                            DropdownMenuItem(value: '4', child: Text('T5')),
                            DropdownMenuItem(value: '5', child: Text('T6')),
                            DropdownMenuItem(value: '6', child: Text('T7')),
                            DropdownMenuItem(value: '0', child: Text('CN')),
                          ],
                          onChanged: (v) => setState(
                              () => _scheduleEntries[idx]['day_of_week'] = v!),
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
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red, size: 20),
                        onPressed: _scheduleEntries.length > 1
                            ? () => setState(
                                () => _scheduleEntries.removeAt(idx))
                            : null,
                      ),
                    ],
                  ),
                );
              }),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _scheduleEntries
                      .add({'day_of_week': '1', 'time': '09:00'})),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm lịch'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppTheme.primaryGold),
                ),
              ),

              const SizedBox(height: 16),
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
                    isEdit ? 'CẬP NHẬT' : 'TẠO KHÓA HỌC',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;
}

// ==============================================================
// TAB 2: LỚP HỌC (Coming Soon)
// ==============================================================

class _ClassroomComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded,
              size: 56, color: AppTheme.primaryGold.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Tính năng Lớp học',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sẽ được phát triển trong phiên bản tiếp theo',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
