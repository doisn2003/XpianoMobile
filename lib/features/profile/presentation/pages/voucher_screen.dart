import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  Future<List<dynamic>> _loadVouchers() async {
    final String response = await rootBundle.loadString('lib/mockdata/vouchers.json');
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho Vouchers'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
        future: _loadVouchers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final vouchers = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              final isUsed = voucher['status'] == 'USED';
              return Opacity(
                opacity: isUsed ? 0.6 : 1.0,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isUsed ? Colors.grey : AppTheme.primaryGold),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isUsed ? Colors.grey : AppTheme.primaryGold.withOpacity(0.1),
                      child: Icon(Icons.confirmation_num, color: isUsed ? Colors.white : AppTheme.primaryGold),
                    ),
                    title: Text(
                      voucher['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Mã: ${voucher['code']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Hết hạn: ${voucher['expiryDate']}'),
                      ],
                    ),
                    trailing: isUsed
                        ? const Chip(label: Text('Đã dùng', style: TextStyle(fontSize: 10)))
                        : const Icon(Icons.chevron_right),
                    onTap: isUsed ? null : () {},
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
}
