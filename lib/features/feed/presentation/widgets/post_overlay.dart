import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_required_dialog.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../pages/user_profile_screen.dart';
import 'comment_bottom_sheet.dart';

/// Overlay UI trên mỗi bài viết trong feed
/// Bao gồm: Thông tin tác giả, tiêu đề, hashtags, nút tương tác
class PostOverlay extends StatelessWidget {
  final Post post;

  const PostOverlay({super.key, required this.post});

  /// Text/image posts dùng màu sáng (textPrimary), video dùng màu trắng
  bool get _isOnDarkBg => post.mediaType == 'video';

  Color get _textColor => _isOnDarkBg ? Colors.white : AppTheme.textPrimary;
  Color get _subTextColor => _isOnDarkBg ? Colors.white70 : AppTheme.textSecondary;
  Color get _iconColor => _isOnDarkBg ? Colors.white : AppTheme.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          // Gradient đen ở dưới — chỉ cho video để text trắng nổi bật
          if (_isOnDarkBg)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 250,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black45, Colors.black87],
                  ),
                ),
              ),
            ),

          // Cột phải: Nút tương tác
          Positioned(
            right: 12,
            bottom: 80,
            child: _InteractionButtons(post: post, iconColor: _iconColor, textColor: _textColor),
          ),

          // Góc trái dưới: thông tin bài viết
          Positioned(
            left: 16,
            right: 72,
            bottom: 12,
            child: _PostInfo(post: post, textColor: _textColor, subTextColor: _subTextColor),
          ),
        ],
    );
  }
}

/// Cột nút tương tác bên phải
class _InteractionButtons extends StatelessWidget {
  final Post post;
  final Color iconColor;
  final Color textColor;

  const _InteractionButtons({required this.post, required this.iconColor, required this.textColor});

  void _handleLike(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final loggedIn = await AuthRequiredDialog.show(context);
      if (!loggedIn || !context.mounted) return;
    }
    if (!context.mounted) return;
    context.read<FeedBloc>().add(FeedToggleLike(post.id, post.isLiked));
  }

  void _handleSave(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final loggedIn = await AuthRequiredDialog.show(context);
      if (!loggedIn || !context.mounted) return;
    }
    if (!context.mounted) return;
    context.read<FeedBloc>().add(FeedToggleSave(post.id, post.isSaved));
  }

  void _openComments(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final loggedIn = await AuthRequiredDialog.show(context);
      if (!loggedIn || !context.mounted) return;
    }
    if (!context.mounted) return;
    CommentBottomSheet.show(context, postId: post.id, commentsCount: post.commentsCount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like (yêu cầu đăng nhập)
        _ActionButton(
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          iconColor: post.isLiked ? const Color(0xFFE53935) : iconColor,
          textColor: textColor,
          count: post.likesCount,
          onTap: () => _handleLike(context),
        ),
        const SizedBox(height: 16),

        // Comment (yêu cầu đăng nhập)
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          iconColor: iconColor,
          textColor: textColor,
          count: post.commentsCount,
          onTap: () => _openComments(context),
        ),
        const SizedBox(height: 16),

        // Share
        _ActionButton(
          icon: Icons.share_outlined,
          iconColor: iconColor,
          textColor: textColor,
          onTap: () => context.read<FeedBloc>().add(FeedSharePost(post.id)),
        ),
        const SizedBox(height: 16),

        // Bookmark / Save
        _ActionButton(
          icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
          iconColor: post.isSaved ? AppTheme.primaryGold : iconColor,
          textColor: textColor,
          onTap: () => _handleSave(context),
        ),
      ],
    );
  }
}

/// Nút tương tác đơn lẻ
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 28),
          if (count != null) ...[
            const SizedBox(height: 2),
            Text(
              _formatCount(count!),
              style: GoogleFonts.nunito(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Thông tin bài viết ở góc trái dưới
class _PostInfo extends StatelessWidget {
  final Post post;
  final Color textColor;
  final Color subTextColor;

  const _PostInfo({required this.post, required this.textColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tên tác giả
        if (post.author != null)
          GestureDetector(
            onTap: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthAuthenticated) {
                final loggedIn = await AuthRequiredDialog.show(context);
                if (!loggedIn || !context.mounted) return;
              }

              if (!context.mounted) return;
              showUserProfileBottomSheet(
                context,
                userId: post.author!.id,
                initialName: post.author!.fullName,
                initialAvatarUrl: post.author!.avatarUrl,
                initialRole: post.author!.role,
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatarWidget(
                  avatarUrl: post.author!.avatarUrl,
                  fullName: post.author!.fullName,
                  role: post.author!.role,
                  radius: 18, // Nhỏ hơn chút cho đẹp khi ngang hàng
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.author!.fullName}',
                  style: GoogleFonts.nunito(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (post.author!.role == 'teacher') ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GV',
                      style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),

        // Title (cho video/image posts)
        if (post.title != null && post.title!.isNotEmpty && post.mediaType != 'none')
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              post.title!,
              style: GoogleFonts.nunito(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Content snippet (cho video/image — bài text hiện ở _TextContent rồi)
        if (post.content != null && post.content!.isNotEmpty && post.mediaType != 'none')
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              post.content!,
              style: GoogleFonts.nunito(color: subTextColor, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Hashtags
        if (post.hashtags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              children: post.hashtags.take(5).map((tag) => Text(
                '#$tag',
                style: GoogleFonts.nunito(
                  color: AppTheme.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )).toList(),
            ),
          ),

        // Location
        if (post.location != null && post.location!.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: subTextColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  post.location!,
                  style: GoogleFonts.nunito(color: subTextColor, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

        // CTA Button
        if (post.relatedPianoId != null || post.relatedCourseId != null) ...[
          const SizedBox(height: 10),
          _CtaButton(post: post),
        ],
      ],
    );
  }
}

/// CTA button context-aware
class _CtaButton extends StatelessWidget {
  final Post post;

  const _CtaButton({required this.post});

  @override
  Widget build(BuildContext context) {
    final isForPiano = post.relatedPianoId != null;
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: navigate to piano detail or course detail
        },
        icon: Icon(isForPiano ? Icons.piano : Icons.school, size: 18),
        label: Text(isForPiano ? 'Mượn Đàn' : 'Học Ngay'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
