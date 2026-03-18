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
    // Thân avatar chính
    Widget avatarBody = CircleAvatar(
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
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );

    if (!_isTeacher) {
      return GestureDetector(
        onTap: onTap,
        child: avatarBody,
      );
    }

    // Với Teacher: Sử dụng Stack để lồng Badge vào viền hở
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Avatar
          avatarBody,

          // 2. Viền gradient có khe hở ở 6 giờ (Custom Painter)
          CustomPaint(
            size: Size((radius + 2.5) * 2, (radius + 2.5) * 2),
            painter: _GradientBorderPainter(
              gradient: AppTheme.goldGradient,
              strokeWidth: 2.5,
              gapWidth: 18.0, // Độ rộng hở để nhét chữ GV
            ),
          ),

          // 3. Badge "GV" lồng vào khe hở
          Positioned(
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'GV',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter vẽ viền tròn với một khe hở ở phía dưới (6 giờ)
class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double gapWidth;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - strokeWidth / 2,
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Tính toán góc hở (radian) dựa trên độ rộng gapWidth
    // Chu vi s = r * theta => theta = s / r
    final double arcRadius = radius - strokeWidth / 2;
    final double gapAngle = gapWidth / arcRadius;

    // Flutter drawArc: 0 là 3 giờ, pi/2 là 6 giờ
    // Bắt đầu từ pi/2 + góc_hở/2 và quét 2*pi - góc_hở
    final double startAngle = (3.1415926535 / 2) + (gapAngle / 2);
    final double sweepAngle = (2 * 3.1415926535) - gapAngle;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gapWidth != gapWidth;
  }
}
