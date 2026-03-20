import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class AffiliateScreen extends StatefulWidget {
  const AffiliateScreen({super.key});

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen> {
  final _dioClient = sl<DioClient>();
  final _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  bool _loading = true;
  String? _error;

  // API data
  Map<String, dynamic>? _affiliateData;
  Map<String, dynamic>? _milestones;
  Map<String, dynamic>? _stats;
  List<dynamic>? _commissions;

  // Not registered yet
  bool _notRegistered = false;
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _dioClient.get('/affiliate/me');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _affiliateData = data['affiliate'];
          _milestones = data['milestones'];
          _stats = data['stats'];
          _commissions = data['commissions'];
          _notRegistered = false;
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Có lỗi xảy ra';
          _loading = false;
        });
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('404') || msg.contains('chưa đăng ký')) {
        setState(() {
          _notRegistered = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    }
  }

  Future<void> _register() async {
    setState(() => _registering = true);
    try {
      final response = await _dioClient.post('/affiliate/register');
      if (response.statusCode == 201 && response.data['success'] == true) {
        await _loadData();
      } else {
        _showSnackBar(response.data['message'] ?? 'Không thể đăng ký');
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _copyReferralLink() {
    final code = _affiliateData?['referral_code'] ?? '';
    final link = 'https://xpiano.vn/ref?code=$code';
    Clipboard.setData(ClipboardData(text: link));
    _showSnackBar('Đã sao chép link giới thiệu!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiếp thị liên kết'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _notRegistered
                    ? _buildRegisterPrompt()
                    : _buildDashboard(),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Register Prompt ──────────────────────────────────────
  Widget _buildRegisterPrompt() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Hero icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.handshake_outlined,
                size: 48, color: Colors.white),
          ),

          const SizedBox(height: 24),
          const Text(
            'Chương trình Affiliate Xpiano',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Giới thiệu bạn bè sử dụng Xpiano và nhận hoa hồng lên đến 15% cho mỗi đơn hàng thành công!',
            style: TextStyle(
                fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Benefits list
          _buildBenefitItem(Icons.music_note, 'Hoa hồng 15% cho khóa học'),
          _buildBenefitItem(
              Icons.piano, 'Hoa hồng 10% cho đơn hàng đàn piano'),
          _buildBenefitItem(Icons.star,
              'Thưởng 500,000₫ mỗi 10 người giới thiệu thành công'),
          _buildBenefitItem(Icons.emoji_events,
              'Thưởng 1,000,000₫ mỗi 50 người giới thiệu thành công'),
          _buildBenefitItem(
              Icons.timer, 'Hoa hồng tính trong 30 ngày đầu đăng ký'),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _registering ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _registering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Đăng ký trở thành Affiliate',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryGoldLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGoldDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  // ─── Dashboard ────────────────────────────────────────────
  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildReferralCard(),
          const SizedBox(height: 16),
          _buildMechanismCard(),
          const SizedBox(height: 16),
          _buildMilestoneCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 24),
          _buildCommissionsSection(),
        ],
      ),
    );
  }

  // ─── 1. Referral Code Card ─────────────────────────────────
  Widget _buildReferralCard() {
    final code = _affiliateData?['referral_code'] ?? '---';
    final status = _affiliateData?['status'] ?? 'active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF996515),
            Color(0xFFDAA520),
            Color(0xFFAA771C),
            Color(0xFFB8860B),
            Color(0xFF5D481C),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                'Mã giới thiệu',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? Colors.green.withOpacity(0.25)
                      : Colors.red.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status == 'active' ? 'Đang hoạt động' : 'Đã khóa',
                  style: TextStyle(
                    color: status == 'active'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            code,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tổng thu nhập: ${_currencyFormat.format(_stats?['lifetime_earned'] ?? 0)}',
            style:
                TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Copy Link Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyReferralLink,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Sao chép link giới thiệu'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Mechanism Guide Card ───────────────────────────────
  Widget _buildMechanismCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGoldLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: AppTheme.primaryGoldDark, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cơ chế hoạt động',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMechanismRow(
              Icons.music_note,
              'Khóa học',
              '15% hoa hồng',
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 8),
            _buildMechanismRow(
              Icons.piano,
              'Đàn Piano',
              '10% hoa hồng',
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 8),
            _buildMechanismRow(
              Icons.timer_outlined,
              'Thời hạn',
              '30 ngày kể từ đăng ký',
              const Color(0xFFFF9800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCreamDarker,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: AppTheme.primaryGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hoa hồng chỉ tính cho đơn hàng được thanh toán trong vòng 30 ngày kể từ ngày người được giới thiệu đăng ký.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMechanismRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  // ─── 3. Milestone Progress Card ────────────────────────────
  Widget _buildMilestoneCard() {
    final currentUsers = _milestones?['current_users'] ?? 0;
    final nextMilestone = _milestones?['next_milestone'] ?? 10;
    final nextBonus = _milestones?['next_bonus_amount'] ?? 500000;
    final progressTarget = _milestones?['progress_target'] ?? 10;
    final progressInCycle = _milestones?['progress_in_current_cycle'] ?? 0;

    final double progressPercent =
        progressTarget > 0 ? (progressInCycle / progressTarget).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGoldLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.emoji_events,
                      color: AppTheme.primaryGoldDark, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mốc thưởng',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current user count
            Center(
              child: Column(
                children: [
                  Text(
                    '$currentUsers',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGoldDark,
                    ),
                  ),
                  Text(
                    'Người giới thiệu thành công',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ đến mốc $nextMilestone người',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary),
                    ),
                    Text(
                      '$progressInCycle / $progressTarget',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 10,
                    backgroundColor: AppTheme.bgCreamDarker,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      nextBonus >= 1000000
                          ? AppTheme.primaryGold
                          : AppTheme.primaryGoldDark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Thưởng: ${_currencyFormat.format(nextBonus)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Milestone tiers
            _buildMilestoneTier(10, 500000,
                currentUsers >= 10, currentUsers),
            const SizedBox(height: 8),
            _buildMilestoneTier(50, 1000000,
                currentUsers >= 50, currentUsers),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneTier(
      int target, int bonus, bool achieved, int current) {
    return Row(
      children: [
        Icon(
          achieved ? Icons.check_circle : Icons.radio_button_unchecked,
          color: achieved ? Colors.green : AppTheme.textSecondary,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: achieved
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                decoration:
                    achieved ? TextDecoration.lineThrough : TextDecoration.none,
              ),
              children: [
                TextSpan(
                    text: 'Mỗi $target người giới thiệu → ',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(
                    text: _currencyFormat.format(bonus),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: achieved
                            ? AppTheme.textSecondary
                            : AppTheme.primaryGoldDark)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── 4. Stats Card ─────────────────────────────────────────
  Widget _buildStatsCard() {
    final pending = _stats?['pending_total'] ?? 0;
    final approved = _stats?['approved_total'] ?? 0;
    final bonusPending = _stats?['bonus_pending_total'] ?? 0;
    final bonusApproved = _stats?['bonus_approved_total'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGoldLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bar_chart,
                      color: AppTheme.primaryGoldDark, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Thống kê thu nhập',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatBox(
                        'Hoa hồng\nđã duyệt',
                        _currencyFormat.format(approved),
                        Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatBox(
                        'Hoa hồng\nchờ duyệt',
                        _currencyFormat.format(pending),
                        Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatBox(
                        'Thưởng\nđã duyệt',
                        _currencyFormat.format(bonusApproved),
                        AppTheme.primaryGoldDark)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatBox(
                        'Thưởng\nchờ duyệt',
                        _currencyFormat.format(bonusPending),
                        AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.3)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ─── 5. Commissions History ────────────────────────────────
  Widget _buildCommissionsSection() {
    final items = _commissions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch sử hoa hồng',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Chưa có hoa hồng nào',
                      style:
                          TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          ...items.map((c) => _buildCommissionItem(c)).toList(),
      ],
    );
  }

  Widget _buildCommissionItem(Map<String, dynamic> c) {
    final amount = (c['amount'] as num?)?.toDouble() ?? 0;
    final status = c['status'] as String? ?? 'pending';
    final isBonus = c['is_bonus'] == true;
    final note = c['note'] as String? ?? '';
    final createdAt = c['created_at'] as String?;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Đã duyệt';
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Chờ duyệt';
        statusIcon = Icons.hourglass_bottom;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isBonus ? AppTheme.primaryGold.withOpacity(0.15) : statusColor.withOpacity(0.1),
          child: Icon(
            isBonus ? Icons.star : Icons.receipt_long,
            color: isBonus ? AppTheme.primaryGold : statusColor,
            size: 20,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isBonus ? '🎁 Thưởng Milestone' : 'Hoa hồng',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(statusText,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(note,
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (createdAt != null)
                    Text(_formatDate(createdAt),
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  if (createdAt == null) const Spacer(),
                  Text(
                    '+${_currencyFormat.format(amount)}',
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
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
}
