import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/course_order_bloc.dart';
import '../bloc/course_order_event.dart';
import '../bloc/course_order_state.dart';

class CourseOrderSheet extends StatefulWidget {
  final Course course;

  const CourseOrderSheet({super.key, required this.course});

  static Future<void> show(BuildContext context, {required Course course}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<CourseOrderBloc>(
        create: (_) => CourseOrderBloc(courseRepository: di.sl<CourseRepository>()),
        child: CourseOrderSheet(course: course),
      ),
    );
  }

  @override
  State<CourseOrderSheet> createState() => _CourseOrderSheetState();
}

class _CourseOrderSheetState extends State<CourseOrderSheet> {
  String _paymentMethod = 'QR';
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  void _submitOrder() {
    context.read<CourseOrderBloc>().add(CreateCourseOrder(
      courseId: widget.course.id,
      paymentMethod: _paymentMethod,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocListener<CourseOrderBloc, CourseOrderState>(
        listener: (context, state) {
          if (state is CourseOrderSuccess) {
            Navigator.pop(context);
            _showSuccessDialog(context, state);
          } else if (state is CourseOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInsets + bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.dividerColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Đăng ký khóa học',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(widget.course.title, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              if (widget.course.teacher != null)
                Text(
                  'Giáo viên: ${widget.course.teacher!.fullName}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              const SizedBox(height: 20),

              // Course info summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.schedule, 'Thời lượng', '${widget.course.durationWeeks} tuần'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.repeat, 'Tần suất', '${widget.course.sessionsPerWeek} buổi/tuần'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.people, 'Đã đăng ký', '${widget.course.enrolledCount}/${widget.course.maxStudents}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Phương thức thanh toán'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentOption('COD', 'Tiền mặt', Icons.money),
                  const SizedBox(width: 12),
                  _buildPaymentOption('QR', 'Chuyển khoản', Icons.qr_code),
                ],
              ),
              const SizedBox(height: 16),

              // Price
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Học phí:', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    Text(
                      widget.course.price > 0 ? currencyFormat.format(widget.course.price) : 'Miễn phí',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              BlocBuilder<CourseOrderBloc, CourseOrderState>(
                builder: (context, state) {
                  final isLoading = state is CourseOrderLoading;
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('XÁC NHẬN ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGold),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isActive = _paymentMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGold.withOpacity(0.1) : AppTheme.bgCream,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppTheme.primaryGold : AppTheme.dividerColor, width: isActive ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? AppTheme.primaryGold : AppTheme.textSecondary, size: 24),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? AppTheme.primaryGold : AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, CourseOrderSuccess state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Đăng ký thành công!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn hàng #${state.orderData['id']} đã được tạo.'),
            const SizedBox(height: 8),
            if (state.orderData['total_price'] != null)
              Text(
                'Tổng thanh toán: ${currencyFormat.format(state.orderData['total_price'])}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGoldDark),
              ),
            if (state.qrUrl != null) ...[
              const SizedBox(height: 12),
              const Text('Quét mã QR để thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Center(child: CachedNetworkImage(imageUrl: state.qrUrl!, width: 200, height: 200)),
            ],
            if (state.orderData['payment_method'] == 'COD')
              const Text('\nNhân viên sẽ liên hệ bạn để xác nhận.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppTheme.primaryGold)),
          ),
        ],
      ),
    );
  }
}
