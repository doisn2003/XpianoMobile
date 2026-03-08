import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_date_range_picker.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/repositories/piano_repository.dart';
import '../bloc/piano_order_bloc.dart';
import '../bloc/piano_order_event.dart';
import '../bloc/piano_order_state.dart';

class PianoOrderSheet extends StatefulWidget {
  final int pianoId;
  final String pianoName;
  final int pricePerDay;
  final int? price;
  final String orderType; // 'buy' or 'rent'

  const PianoOrderSheet({
    super.key,
    required this.pianoId,
    required this.pianoName,
    required this.pricePerDay,
    this.price,
    required this.orderType,
  });

  static Future<void> show(
    BuildContext context, {
    required int pianoId,
    required String pianoName,
    required int pricePerDay,
    int? price,
    required String orderType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<PianoOrderBloc>(
        create: (_) => PianoOrderBloc(pianoRepository: di.sl<PianoRepository>()),
        child: PianoOrderSheet(
          pianoId: pianoId,
          pianoName: pianoName,
          pricePerDay: pricePerDay,
          price: price,
          orderType: orderType,
        ),
      ),
    );
  }

  @override
  State<PianoOrderSheet> createState() => _PianoOrderSheetState();
}

class _PianoOrderSheetState extends State<PianoOrderSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _paymentMethod = 'COD';

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  int _calculateRentalPrice() {
    if (_startDate == null || _endDate == null) return 0;
    int days = _rentalDays;
    if (days < 1) return 0;
    
    int basePrice = widget.pricePerDay * days;
    if (days >= 8) return (basePrice * 0.85).round();
    if (days >= 3) return (basePrice * 0.90).round();
    return basePrice;
  }

  int _calculateBuyPrice() {
    if (widget.price != null && widget.price! > 0) return widget.price!;
    return widget.pricePerDay * 100;
  }


  void _selectDateRange() async {
    final picked = await AppDateRangePicker.show(
      context,
      initialStartDate: _startDate,
      initialEndDate: _endDate,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submitOrder() {
    if (widget.orderType == 'rent' && (_startDate == null || _endDate == null || _rentalDays < 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày thuê hợp lệ (ít nhất 1 ngày)')),
      );
      return;
    }

    context.read<PianoOrderBloc>().add(CreatePianoOrder(
      pianoId: widget.pianoId,
      type: widget.orderType,
      rentalStartDate: _startDate?.toIso8601String(),
      rentalEndDate: _endDate?.toIso8601String(),
      paymentMethod: _paymentMethod,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocListener<PianoOrderBloc, PianoOrderState>(
        listener: (context, state) {
          if (state is PianoOrderSuccess) {
            Navigator.pop(context);
            _showOrderSuccessDialog(context, state);
          } else if (state is PianoOrderError) {
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
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.dividerColor, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.orderType == 'buy' ? 'Xác nhận mua đàn' : 'Xác nhận thuê đàn',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(widget.pianoName, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),

              // Nếu là thuê: chọn ngày
              if (widget.orderType == 'rent') ...[
                _buildSectionTitle('Chọn ngày thuê'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range, color: AppTheme.primaryGold),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} → ${DateFormat('dd/MM/yyyy').format(_endDate!)} ($_rentalDays ngày)'
                        : 'Chọn ngày bắt đầu và kết thúc',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.dividerColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 8),
                // Giá tham khảo — KHÔNG phải giá chính thức
                Text(
                  'Giá tham khảo: ${currencyFormat.format(widget.pricePerDay)}/ngày',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
              ],

              // Phương thức thanh toán
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

              // Khối hiển thị giá tạm tính
              if (widget.orderType == 'rent' && _startDate != null && _endDate != null && _rentalDays > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Thời gian thuê: $_rentalDays ngày',
                        style: TextStyle(fontSize: 14, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                      ),
                      if (_rentalDays >= 3) ...[
                        const SizedBox(height: 4),
                        Text(
                          '🎉 Giảm ${_rentalDays >= 8 ? '15%' : '10%'} cho thuê dài hạn!',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              if (widget.orderType == 'buy' || (widget.orderType == 'rent' && _startDate != null && _endDate != null && _rentalDays > 0)) ...[
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
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        currencyFormat.format(widget.orderType == 'buy' ? _calculateBuyPrice() : _calculateRentalPrice()),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: AppTheme.bgCream,
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: AppTheme.dividerColor),
                   ),
                   child: const Row(
                     children: [
                       Icon(Icons.info_outline, color: AppTheme.primaryGold, size: 18),
                       SizedBox(width: 8),
                       Expanded(
                         child: Text(
                           'Vui lòng chọn ngày để xem giá tạm tính.',
                           style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),
              ],

              // Nút đặt hàng
              BlocBuilder<PianoOrderBloc, PianoOrderState>(
                builder: (context, state) {
                  final isLoading = state is PianoOrderLoading;
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
                          : const Text('XÁC NHẬN ĐẶT HÀNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showOrderSuccessDialog(BuildContext context, PianoOrderSuccess state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Đặt hàng thành công!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn hàng #${state.orderData['id']} đã được tạo.'),
            const SizedBox(height: 8),
            // Hiển thị giá từ server
            if (state.orderData['total_price'] != null)
              Text(
                'Tổng thanh toán: ${currencyFormat.format(state.orderData['total_price'])}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGoldDark),
              ),
            if (state.orderData['rental_days'] != null)
              Text('Số ngày thuê: ${state.orderData['rental_days']} ngày'),
            if (state.qrUrl != null) ...[
              const SizedBox(height: 12),
              const Text('Quét mã QR để thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Center(
                child: Image.network(state.qrUrl!, width: 200, height: 200),
              ),
            ],
            if (state.orderData['payment_method'] == 'COD')
              const Text('\nNhân viên sẽ liên hệ bạn để xác nhận đơn hàng.'),
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
