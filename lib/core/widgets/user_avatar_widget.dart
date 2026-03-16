import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Widget hiển thị avatar người dùng.
/// Nếu role == 'teacher' sẽ có viền vàng gradient và badge "GV" bên dưới.
class UserAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final String role;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.role = 'user',
    this.radius = 22,
    this.onTap,
  });

  bool get _isTeacher => role == 'teacher';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar với viền gradient cho teacher
          Container(
            padding: EdgeInsets.all(_isTeacher ? 2.5 : 0),
            decoration: _isTeacher
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                  )
                : null,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: _isTeacher ? AppTheme.bgCream : AppTheme.primaryGold,
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(
                      avatarUrl!,
                      maxHeight: 150, // Tránh phình to RAM
                      maxWidth: 150,
                    )
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: radius * 0.8,
                      ),
                    )
                  : null,
            ),
          ),

          // Badge "GV" cho teacher
          if (_isTeacher) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'GV',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
