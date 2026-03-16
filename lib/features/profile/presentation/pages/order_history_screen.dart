import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersBloc(repository: sl())..add(LoadOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử đơn hàng'),
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
                      onPressed: () => context.read<OrdersBloc>().add(LoadOrders()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            } else if (state is OrdersLoaded) {
              final orders = state.orders;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Chưa có đơn hàng nào', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _OrderCard(order: orders[index]);
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

class _OrderCard extends StatelessWidget {
  final OrderItem order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    String statusText;
    Color statusColor;
    switch (order.status) {
      case 'pending':
        statusText = 'Chờ xử lý';
        statusColor = Colors.orange;
        break;
      case 'approved':
      case 'completed':
        statusText = 'Hoàn thành';
        statusColor = Colors.green;
        break;
      case 'rejected':
      case 'cancelled':
        statusText = 'Đã hủy';
        statusColor = Colors.red;
        break;
      default:
        statusText = order.status;
        statusColor = Colors.grey;
    }

    String typeText = order.type == 'course' ? 'Khóa học' : (order.type == 'rent' ? 'Thuê đàn' : 'Mua đàn');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mã đơn: #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.piano != null && order.piano!.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(order.piano!.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCreamDarker,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, color: AppTheme.textSecondary),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.piano?.name ?? (order.type == 'course' ? 'Khóa học Xpiano' : 'Đàn Piano'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('Loại: $typeText', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(order.totalPrice),
                        style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (order.createdAt != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ngày đặt: ${_formatDate(order.createdAt!)}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
    } catch (_) {
      return isoString;
    }
  }
}
