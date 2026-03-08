import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/piano.dart';

class PianoCardWidget extends StatelessWidget {
  final Piano piano;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;

  const PianoCardWidget({
    super.key,
    required this.piano,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh + Badge category + Heart icon
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Ảnh đàn
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCreamDarker,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: piano.imageUrl != null && piano.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              piano.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                            ),
                          )
                        : _buildPlaceholderImage(),
                  ),

                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        piano.category,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Favorite heart icon
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.red : AppTheme.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 1, 10, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên đàn
                    Text(
                      piano.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Mô tả ngắn
                    if (piano.description != null && piano.description!.isNotEmpty)
                      Text(
                        piano.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                      ),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.primaryGold, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          piano.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          ' (${piano.reviewsCount})',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Giá
                    Text(
                      '${currencyFormat.format(piano.pricePerDay)}/ngày',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGoldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.piano, size: 40, color: AppTheme.textSecondary.withOpacity(0.3)),
    );
  }
}
