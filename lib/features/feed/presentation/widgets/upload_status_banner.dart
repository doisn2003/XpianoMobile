import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';

/// Global Upload Status Banner — overlay nổi trên nội dung màn hình.
///
/// - **Uploading:** Spinner + "Đang đăng bài..." + progress + nút `<` thu gọn
/// - **Thành công:** "Đã đăng bài thành công" + "Xem ngay" → tự ẩn sau 10s
/// - **Lỗi:** "Đăng bài thất bại" + chi tiết lỗi
/// - Thu gọn: chỉ hiện icon nhỏ bên trái
class UploadStatusBanner extends StatefulWidget {
  final VoidCallback onViewPost;

  const UploadStatusBanner({super.key, required this.onViewPost});

  @override
  State<UploadStatusBanner> createState() => _UploadStatusBannerState();
}

class _UploadStatusBannerState extends State<UploadStatusBanner>
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;
  bool _isHidden = false; // true khi tự ẩn sau 10s
  Timer? _autoDismissTimer;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.value = 1.0; // bắt đầu hiện
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() => _isCollapsed = !_isCollapsed);
  }

  void _startAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 10), () {
      // Fade out rồi dismiss
      _fadeController.reverse().then((_) {
        if (mounted) {
          context.read<CreatePostBloc>().add(DismissUploadStatus());
          setState(() => _isHidden = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatePostBloc, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostUploading || state is CreatePostError) {
          // Reset khi có upload mới hoặc lỗi
          _autoDismissTimer?.cancel();
          _isHidden = false;
          _isCollapsed = false;
          _fadeController.value = 1.0;
        } else if (state is CreatePostSuccess) {
          // Bắt đầu đếm 10s để tự ẩn
          _isHidden = false;
          _fadeController.value = 1.0;
          _startAutoDismiss();
        } else if (state is CreatePostInitial) {
          _isHidden = true;
          _autoDismissTimer?.cancel();
        }
      },
      builder: (context, state) {
        // Ẩn hoàn toàn
        if (state is CreatePostInitial ||
            state is CreatePostEditing ||
            _isHidden) {
          return const SizedBox.shrink();
        }

        final topPadding = MediaQuery.of(context).padding.top;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: _isCollapsed
              ? _buildCollapsedBanner(state, topPadding)
              : _buildExpandedBanner(context, state, topPadding),
        );
      },
    );
  }

  Widget _buildCollapsedBanner(CreatePostState state, double topPadding) {
    return Positioned(
      // Thu gọn: nằm ngay dưới status bar
      top: topPadding + 8,
      left: 8,
      child: GestureDetector(
        onTap: _toggleCollapse,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getBannerColor(state),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _getBannerColor(state).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getStatusIcon(state, size: 16),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedBanner(
      BuildContext context, CreatePostState state, double topPadding) {
    return Positioned(
      // Bắt đầu từ top: 0, phủ màu lên toàn bộ vùng status bar
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        // Bo góc dưới, không bo góc trên (sát cạnh màn hình)
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: _getBannerColor(state).withValues(alpha: 0.95),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: _getBannerColor(state).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    // topPadding đẩy nội dung xuống dưới dòng trạng thái hệ thống
                    padding: EdgeInsets.fromLTRB(14, topPadding + 8, 6, 6),
                    child: Row(
                      children: [
                        _getStatusIcon(state, size: 22),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatusContent(state)),
                        _buildActionButton(context, state),
                        // Nút thu gọn
                        IconButton(
                          onPressed: _toggleCollapse,
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.white, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                  // Progress bar
                  if (state is CreatePostUploading)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  if (state is! CreatePostUploading) const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent(CreatePostState state) {
    if (state is CreatePostUploading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Đang đăng bài...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            state.statusMessage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (state is CreatePostSuccess) {
      return const Text(
        'Đã đăng bài thành công',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    }

    if (state is CreatePostError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Đăng bài thất bại',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            state.message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton(BuildContext context, CreatePostState state) {
    if (state is CreatePostSuccess) {
      return GestureDetector(
        onTap: () {
          _autoDismissTimer?.cancel();
          context.read<CreatePostBloc>().add(DismissUploadStatus());
          widget.onViewPost();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Xem ngay',
            style: TextStyle(
              color: AppTheme.primaryGoldDark,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _getStatusIcon(CreatePostState state, {double size = 20}) {
    if (state is CreatePostUploading) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          value: state.progress > 0 ? state.progress : null,
        ),
      );
    }
    if (state is CreatePostSuccess) {
      return Icon(Icons.check_circle, color: Colors.white, size: size);
    }
    if (state is CreatePostError) {
      return Icon(Icons.error_outline, color: Colors.white, size: size);
    }
    return const SizedBox.shrink();
  }

  Color _getBannerColor(CreatePostState state) {
    if (state is CreatePostUploading) return AppTheme.primaryGoldDark;
    if (state is CreatePostSuccess) return const Color(0xFF2E7D32);
    if (state is CreatePostError) return const Color(0xFFC62828);
    return AppTheme.primaryGoldDark;
  }
}
