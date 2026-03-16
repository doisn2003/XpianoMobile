import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction.dart' as t_entity;
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletBloc(repository: sl())..add(LoadWallet()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletWithdrawalSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is WalletError && !state.message.contains('Failed to load wallet')) {
            // Only show error dialog for actions like withdrawal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WalletError && state.message.contains('Failed to load wallet')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Không thể tải thông tin ví', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WalletBloc>().add(LoadWallet()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (state is WalletLoaded) {
            final wallet = state.wallet;
            final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(LoadWallet());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Số dư khả dụng',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(wallet.availableBalance),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceItem('Đang chờ xử lý', currencyFormat.format(wallet.lockedBalance)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  ElevatedButton.icon(
                    onPressed: () => _showWithdrawalDialog(context, wallet.availableBalance),
                    icon: const Icon(Icons.payments),
                    label: const Text('Yêu cầu rút tiền', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Transactions
                  const Text('Lịch sử giao dịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),

                  if (wallet.transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text('Chưa có giao dịch nào', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    )
                  else
                    ...wallet.transactions.map((tx) => _buildTransactionItem(tx, currencyFormat)).toList(),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTransactionItem(t_entity.Transaction tx, NumberFormat format) {
    final isIncome = tx.type == 'IN';
    final amountColor = isIncome ? Colors.green : Colors.red;
    final prefix = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: amountColor,
          ),
        ),
        title: Text(tx.note ?? (isIncome ? 'Nhận tiền' : 'Rút tiền'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: tx.createdAt != null 
            ? Text(_formatDate(tx.createdAt!), style: const TextStyle(fontSize: 12))
            : null,
        trailing: Text(
          '$prefix${format.format(tx.amount)}',
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
    } catch (_) {
      return isoString;
    }
  }

  void _showWithdrawalDialog(BuildContext context, double availableBalance) {
    final bloc = context.read<WalletBloc>();
    final amountController = TextEditingController();
    final bankNameController = TextEditingController();
    final accountNumController = TextEditingController();
    final accountNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Rút tiền'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khả dụng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(availableBalance)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Số tiền rút (VND)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(labelText: 'Tên ngân hàng (VD: MB Bank)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNumController,
                  decoration: const InputDecoration(labelText: 'Số tài khoản', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNameController,
                  decoration: const InputDecoration(labelText: 'Tên chủ tài khoản', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount < 50000) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số tiền rút tối thiểu là 50,000 VND')));
                  return;
                }
                if (amount > availableBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số dư không đủ')));
                  return;
                }
                if (bankNameController.text.isEmpty || accountNumController.text.isEmpty || accountNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin ngân hàng')));
                  return;
                }

                bloc.add(RequestWithdrawal(
                  amount: amount,
                  bankInfo: {
                    'bank_name': bankNameController.text,
                    'account_number': accountNumController.text,
                    'account_name': accountNameController.text,
                  },
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
