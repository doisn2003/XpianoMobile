import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_required_dialog.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/post_repository.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';

/// Bottom sheet popup hiển thị bình luận bài viết.
/// Gọn, nhẹ, đẹp.
class CommentBottomSheet extends StatelessWidget {
  final String postId;
  final int commentsCount;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.commentsCount,
  });

  /// Hiển thị popup.
  static Future<void> show(BuildContext context, {required String postId, int commentsCount = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // Truyền AuthBloc từ context cha
        final authBloc = context.read<AuthBloc>();
        return BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: CommentBottomSheet(postId: postId, commentsCount: commentsCount),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommentBloc(
        postRepository: GetIt.instance<PostRepository>(),
      )..add(CommentLoadRequested(postId)),
      child: _CommentSheetBody(postId: postId, commentsCount: commentsCount),
    );
  }
}

class _CommentSheetBody extends StatefulWidget {
  final String postId;
  final int commentsCount;

  const _CommentSheetBody({required this.postId, required this.commentsCount});

  @override
  State<_CommentSheetBody> createState() => _CommentSheetBodyState();
}

class _CommentSheetBodyState extends State<_CommentSheetBody> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      context.read<CommentBloc>().add(CommentLoadMore());
    }
  }

  void _submitComment() async {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    // Kiểm tra auth
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final loggedIn = await AuthRequiredDialog.show(context);
      if (!loggedIn || !mounted) return;
    }

    if (!mounted) return;
    context.read<CommentBloc>().add(CommentSubmitted(content));
    _textController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Fix cho Navigation Bar hệ thống bị đè:
    final effectiveBottomPadding = bottomInsets > 0 ? bottomInsets : bottomPadding;

    return Container(
      height: screenHeight * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar + Header
          _buildHeader(),

          const Divider(height: 1, color: AppTheme.dividerColor),

          // Comment list
          Expanded(
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
                }

                if (state is CommentError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Không thể tải bình luận',
                        style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                  );
                }

                if (state is CommentLoaded) {
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 40, color: AppTheme.textSecondary.withValues(alpha: 80)),
                          const SizedBox(height: 8),
                          Text('Chưa có bình luận', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Hãy là người đầu tiên bình luận!', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.comments.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.comments.length) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2)),
                        );
                      }
                      return _CommentTile(
                        comment: state.comments[index],
                        currentUserId: _getCurrentUserId(),
                        onDelete: (id) => context.read<CommentBloc>().add(CommentDeleted(id)),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: 8 + effectiveBottomPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận...',
                        hintStyle: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    final isSubmitting = state is CommentLoaded && state.isSubmitting;
                    return GestureDetector(
                      onTap: isSubmitting ? null : _submitComment,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          shape: BoxShape.circle,
                        ),
                        child: isSubmitting
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withValues(alpha: 60),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${widget.commentsCount} bình luận',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id.toString();
    }
    return null;
  }
}

/// Tile hiển thị 1 bình luận
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final String? currentUserId;
  final void Function(String commentId) onDelete;

  const _CommentTile({
    required this.comment,
    this.currentUserId,
    required this.onDelete,
  });

  bool get _isOwner => currentUserId != null && comment.userId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          UserAvatarWidget(
            avatarUrl: comment.author?.avatarUrl,
            fullName: comment.author?.fullName ?? '',
            role: comment.author?.role ?? 'user',
            radius: 16,
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author?.fullName ?? 'Ẩn danh',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (comment.author?.role == 'teacher') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'GV',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  comment.content,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary),
                ),

                // Delete button for own comments
                if (_isOwner)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Xóa',
                          style: GoogleFonts.outfit(color: Colors.red.shade400, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xóa bình luận?', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('Bạn có chắc muốn xóa bình luận này?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(comment.id);
            },
            child: Text('Xóa', style: GoogleFonts.outfit(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Vừa xong';
  }
}
