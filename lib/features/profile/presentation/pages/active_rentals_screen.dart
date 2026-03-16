import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../piano/domain/entities/piano.dart';
import '../../../piano/presentation/pages/piano_detail_screen.dart';
import '../../domain/entities/active_rental.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class ActiveRentalsScreen extends StatelessWidget {
  const ActiveRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersBloc(repository: sl())..add(LoadActiveRentals()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đàn piano đang thuê'),
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<OrdersBloc>().add(LoadActiveRentals()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else if (state is ActiveRentalsLoaded) {
              final rentals = state.rentals;

              if (rentals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.piano, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Bạn chưa thuê cây đàn nào', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  return _ActiveRentalCard(rental: rentals[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ActiveRentalCard extends StatelessWidget {
  final ActiveRental rental;

  const _ActiveRentalCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    // Calculate remaining days
    final endDateStr = rental.endDate;
    DateTime? endDate;
    int remainingDays = 0;
    
    if (endDateStr.isNotEmpty) {
      endDate = DateTime.tryParse(endDateStr);
      if (endDate != null) {
        remainingDays = endDate.difference(DateTime.now()).inDays;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Piano Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: rental.piano?.imageUrl != null && rental.piano!.imageUrl.isNotEmpty
                      ? Image.network(rental.piano!.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                      : Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.bgCreamDarker,
                          child: const Icon(Icons.piano, color: AppTheme.textSecondary),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental.piano?.name ?? 'Piano không rõ tên',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng giá thuê: ${currencyFormat.format(rental.totalPrice)}',
                        style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Details
            _buildDetailRow('Ngày bắt đầu', _formatDate(rental.startDate)),
            const SizedBox(height: 8),
            _buildDetailRow('Ngày kết thúc', _formatDate(rental.endDate)),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Thời gian còn lại', 
              remainingDays > 0 ? '$remainingDays ngày' : (remainingDays == 0 ? 'Hết hạn hôm nay' : 'Đã quá hạn'),
              color: remainingDays <= 3 ? Colors.red : AppTheme.textPrimary,
              isBold: remainingDays <= 3,
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (rental.piano != null) {
                    // Create dummy piano with required fields to pass to DetailScreen
                    final mockPiano = Piano(
                      id: int.tryParse(rental.piano!.id) ?? 0,
                      name: rental.piano!.name,
                      category: rental.piano!.category,
                      imageUrl: rental.piano!.imageUrl,
                      pricePerDay: rental.piano?.pricePerDay ?? 0, // Dùng dữ liệu thật từ backend
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PianoDetailScreen(pianoId: mockPiano.id),
                      ),
                    );
                  }
                },
                child: const Text('Gia hạn thêm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color color = AppTheme.textSecondary, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(
          value, 
          style: TextStyle(
            color: color, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
    } catch (_) {
      return isoString;
    }
  }
}
