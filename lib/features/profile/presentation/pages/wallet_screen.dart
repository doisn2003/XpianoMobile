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
import 'earn_money_screen.dart';
import 'voucher_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<WalletBloc>(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
      ),
      body: SafeArea(
        child: BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletWithdrawalSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is WalletError && !state.message.contains('Failed to load wallet')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletInitial) {
              context.read<WalletBloc>().add(LoadWallet());
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WalletError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<WalletBloc>().add(LoadWallet()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (state is WalletWithdrawalSuccess) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WalletLoaded) {
              final wallet = state.wallet;
              final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

              // Apply Filter
              final filteredTransactions = wallet.transactions.where((tx) {
                if (_filter == 'ALL') return true;
                return tx.type == _filter;
              }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletBloc>().add(LoadWallet());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF996515), // Gold Brown
                            Color(0xFFDAA520), // Goldenrod Highlight
                            Color(0xFFAA771C), // Deep Gold
                            Color(0xFFB8860B), // Dark Goldenrod
                            Color(0xFF5D481C), // Deep Bronze
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D481C).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số dư khả dụng',
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currencyFormat.format(wallet.availableBalance),
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Đang chờ xử lý',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currencyFormat.format(wallet.lockedBalance),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Action Buttons in a compact 2x2 grid
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  _buildCardActionButton(
                                    icon: Icons.add_card,
                                    label: 'Nạp tiền',
                                    onTap: () => _showDepositDialog(context),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildCardActionButton(
                                    icon: Icons.payments_outlined,
                                    label: 'Rút tiền',
                                    onTap: () => _showWithdrawalDialog(context, wallet.availableBalance),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildCardActionButton(
                                    icon: Icons.paid,
                                    label: 'Kiếm tiền',
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarnMoneyScreen())),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildCardActionButton(
                                    icon: Icons.confirmation_number,
                                    label: 'Vouchers',
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherScreen())),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Transactions Header with Compact Filter
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Lịch sử giao dịch',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ),
                        _buildFilterButton('Tất cả', 'ALL'),
                        const SizedBox(width: 4),
                        _buildFilterButton('Nhận ', 'IN'),
                        const SizedBox(width: 4),
                        _buildFilterButton(' Rút  ', 'OUT'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (filteredTransactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('Chưa có giao dịch nào', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      )
                    else
                      ...filteredTransactions.map((tx) => _buildTransactionItem(tx, currencyFormat)).toList(),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGold : AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
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
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 12),
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
          title: const Text('Yêu cầu rút tiền'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khả dụng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(availableBalance)}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Số tiền rút (VND)',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Tên ngân hàng (VD: MB Bank)',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNumController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Số tài khoản',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Tên chủ tài khoản',
                    labelStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(),
                  ),
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
                final amountText = amountController.text.replaceAll(' ', '');
                final amount = double.tryParse(amountText) ?? 0;
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

  void _showDepositDialog(BuildContext context) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nạp tiền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập số tiền bạn muốn nạp vào ví Xpiano', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Số tiền (VND)',
                border: OutlineInputBorder(),
                prefixText: '₫ ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isEmpty) return;
              Navigator.pop(ctx);
              _showQRCodeModal(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showQRCodeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tính năng đang được phát triển',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng quay lại sau!',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 65, // Fixed width for consistent grid alignment
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Strip existing spaces
    String text = newValue.text.replaceAll(' ', '');
    
    // Format with spaces
    StringBuffer newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        newText.write(' ');
      }
      newText.write(text[i]);
    }

    String formatted = newText.toString();
    
    // Basic cursor positioning logic
    int selectionOffset = newValue.selection.end;
    
    // Adjust offset for added/removed spaces
    int digitsBeforeSelection = newValue.text.substring(0, selectionOffset).replaceAll(' ', '').length;
    int newOffset = 0;
    int digitCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (formatted[i] != ' ') {
        digitCount++;
      }
      if (digitCount == digitsBeforeSelection) {
        newOffset = i + 1;
        break;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
