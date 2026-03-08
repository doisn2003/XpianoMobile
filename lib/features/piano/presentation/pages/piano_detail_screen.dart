import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_required_dialog.dart';
import '../../domain/repositories/piano_repository.dart';
import '../bloc/piano_detail_bloc.dart';
import '../bloc/piano_detail_event.dart';
import '../bloc/piano_detail_state.dart';
import '../widgets/piano_order_sheet.dart';

class PianoDetailScreen extends StatelessWidget {
  final int pianoId;

  const PianoDetailScreen({super.key, required this.pianoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PianoDetailBloc>(
      create: (_) => PianoDetailBloc(pianoRepository: di.sl<PianoRepository>())..add(LoadPianoDetail(pianoId)),
      child: const _PianoDetailView(),
    );
  }
}

class _PianoDetailView extends StatelessWidget {
  const _PianoDetailView();

  Future<bool> _ensureAuth(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return true;
    return await AuthRequiredDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: BlocBuilder<PianoDetailBloc, PianoDetailState>(
        builder: (context, state) {
          if (state is PianoDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          if (state is PianoDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          if (state is PianoDetailLoaded) {
            final piano = state.piano;
            return CustomScrollView(
              slivers: [
                // Hero image AppBar
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: AppTheme.cardWhite,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),

                  flexibleSpace: FlexibleSpaceBar(
                    background: piano.imageUrl != null && piano.imageUrl!.isNotEmpty
                        ? Image.network(
                            piano.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderHero(),
                          )
                        : _buildPlaceholderHero(),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge & Favorite icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                piano.category,
                                style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final authed = await _ensureAuth(context);
                                if (authed && context.mounted) {
                                  context.read<PianoDetailBloc>().add(
                                    TogglePianoFavorite(piano.id, state.isFavorited),
                                  );
                                }
                              },
                              child: Icon(
                                state.isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: state.isFavorited ? Colors.red : AppTheme.textSecondary,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Name
                        Text(
                          piano.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 8),

                        // Rating & Reviews
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < piano.rating.round() ? Icons.star : Icons.star_border,
                                color: AppTheme.primaryGold,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${piano.rating.toStringAsFixed(1)} (${piano.reviewsCount} đánh giá)',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Pricing cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriceCard(
                                'Mượn',
                                '${currencyFormat.format(piano.pricePerDay)}/ngày',
                                Icons.access_time,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPriceCard(
                                'Mua',
                                piano.price != null ? currencyFormat.format(piano.price) : 'Liên hệ',
                                Icons.shopping_cart,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Mô tả
                        if (piano.description != null && piano.description!.isNotEmpty) ...[
                          const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 8),
                          Text(
                            piano.description!,
                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Features
                        if (piano.features.isNotEmpty) ...[
                          const Text('Đặc điểm nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: piano.features.map((f) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCreamDarker,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.dividerColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, color: AppTheme.primaryGold, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(child: Text(f, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary))),
                                ],
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),

      // Bottom CTA bar
      bottomNavigationBar: BlocBuilder<PianoDetailBloc, PianoDetailState>(
        builder: (context, state) {
          if (state is! PianoDetailLoaded) return const SizedBox.shrink();
          final piano = state.piano;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Mượn button (outlined)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          final authed = await _ensureAuth(context);
                          if (authed && context.mounted) {
                            PianoOrderSheet.show(
                              context,
                              pianoId: piano.id,
                              pianoName: piano.name,
                              pricePerDay: piano.pricePerDay,
                              orderType: 'rent',
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGoldDark,
                          side: const BorderSide(color: AppTheme.primaryGold, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('MƯỢN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mua button (filled gold gradient)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final authed = await _ensureAuth(context);
                            if (authed && context.mounted) {
                              PianoOrderSheet.show(
                                context,
                                pianoId: piano.id,
                                pianoName: piano.name,
                                pricePerDay: piano.pricePerDay,
                                orderType: 'buy',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('MUA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderHero() {
    return Container(
      color: AppTheme.bgCreamDarker,
      child: Center(
        child: Icon(Icons.piano, size: 80, color: AppTheme.textSecondary.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildPriceCard(String label, String price, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryGold),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark)),
        ],
      ),
    );
  }
}
