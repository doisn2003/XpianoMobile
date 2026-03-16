import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/course.dart';

class CourseCardWidget extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCardWidget({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final thumbnailUrl = ImageUtils.optimizedCourseThumbnail(
      course.thumbnailUrl ?? course.coverUrl,
    );

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail (fixed aspect ratio)
            AspectRatio(
              aspectRatio: 12 / 10,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.bgCreamDarker,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: thumbnailUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: CachedNetworkImage(
                              imageUrl: thumbnailUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (_, __) => _buildPlaceholder(),
                              errorWidget: (_, __, ___) => _buildPlaceholder(),
                            ),
                          )
                        : _buildPlaceholder(),
                  ),
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
                        course.isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section -- expands to fill remaining grid cell height
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title (centered, max 2 lines, ellipsis)
                    Text(
                      course.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),

                    // Description (centered, max 2 lines)
                    if (course.description != null && course.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          course.description!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                        ),
                      ),

                    // Teacher
                    if (course.teacher != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTeacherAvatar(),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                course.teacher!.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Push price to bottom
                    const Spacer(),

                    // Duration row (centered)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${course.durationWeeks} tuần',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price (centered, always at bottom)
                    Text(
                      course.price > 0 ? currencyFormat.format(course.price) : 'Miễn phí',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
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

  Widget _buildTeacherAvatar() {
    final avatarUrl = ImageUtils.optimizedAvatar(course.teacher?.avatarUrl);
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 8,
        backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: 8,
      backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
      child: Text(
        course.teacher!.fullName.isNotEmpty ? course.teacher!.fullName[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 8, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.school, size: 40, color: AppTheme.textSecondary.withOpacity(0.3)),
    );
  }
}
