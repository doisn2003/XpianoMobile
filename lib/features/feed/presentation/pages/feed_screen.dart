import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../manager/feed_video_manager.dart';
import '../widgets/post_overlay.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Feed Screen — TikTok-style vuốt dọc full-screen
class FeedScreen extends StatelessWidget {
  final bool isTabActive;
  const FeedScreen({super.key, required this.isTabActive});

  @override
  Widget build(BuildContext context) {
    String? currentUserId;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id.toString();
    }

    return BlocProvider(
      create: (_) => FeedBloc(
        postRepository: GetIt.instance<PostRepository>(),
      )..add(FeedLoadRequested(currentUserId: currentUserId)),
      child: _FeedBody(isTabActive: isTabActive),
    );
  }
}

class _FeedBody extends StatefulWidget {
  final bool isTabActive;
  const _FeedBody({required this.isTabActive});

  @override
  State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final PageController _pageController = PageController();
  Timer? _viewTimer;
  int _currentPage = 0;
  bool _initialPreloaded = false;

  @override
  void dispose() {
    _pageController.dispose();
    _viewTimer?.cancel();
    super.dispose();
  }

  void _onPageChanged(int index, List<Post> posts) {
    setState(() => _currentPage = index);

    _viewTimer?.cancel();
    _viewTimer = Timer(const Duration(seconds: 3), () {
      if (index < posts.length) {
        context.read<FeedBloc>().add(FeedTrackView(posts[index].id));
      }
    });

    if (index >= posts.length - 3) {
      String? currentUserId;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) currentUserId = authState.user.id.toString();
      
      context.read<FeedBloc>().add(FeedLoadMore(currentUserId: currentUserId));
    }

    _manageVideoPool(index, posts);
  }

  void _manageVideoPool(int index, List<Post> posts) {
    final keepIds = <String>[];
    final preloadInfos = <Map<String, String>>[];
    
    // Giữ video hiện tại, 1 trước, 2 sau
    for (int i = index - 1; i <= index + 2; i++) {
      if (i >= 0 && i < posts.length) {
        final p = posts[i];
        if (p.mediaType == 'video' && p.mediaUrls.isNotEmpty) {
          keepIds.add(p.id);
          preloadInfos.add({'id': p.id, 'url': p.mediaUrls.first});
        }
      }
    }
    
    FeedVideoManager().preloadVideos(preloadInfos);
    FeedVideoManager().disposeOutOfRange(keepIds);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
          );
        }

        if (state is FeedError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: AppTheme.textSecondary.withValues(alpha: 128), size: 64),
                  const SizedBox(height: 16),
                  Text('Không thể tải feed', style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
                  )),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: GoogleFonts.nunito(color: AppTheme.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      String? currentUserId;
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) currentUserId = authState.user.id.toString();
                      context.read<FeedBloc>().add(FeedLoadRequested(currentUserId: currentUserId));
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is FeedLoaded) {
          if (!_initialPreloaded && state.posts.isNotEmpty) {
            _initialPreloaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _manageVideoPool(0, state.posts);
            });
          }

          if (state.posts.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note_outlined, size: 80, color: AppTheme.primaryGold.withValues(alpha: 77)),
                    const SizedBox(height: 16),
                    Text('Chưa có bài viết nào', style: GoogleFonts.nunito(
                      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
                    )),
                    const SizedBox(height: 8),
                    Text('Hãy là người đầu tiên chia sẻ!', style: GoogleFonts.nunito(
                      color: AppTheme.textSecondary, fontSize: 14,
                    )),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: SafeArea(
              bottom: false, // Bottom đã có navbar
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.posts.length,
                onPageChanged: (index) => _onPageChanged(index, state.posts),
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return _PostPage(
                    post: post,
                    isActive: index == _currentPage,
                    isTabActive: widget.isTabActive,
                  );
                },
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Mỗi trang trong PageView
class _PostPage extends StatefulWidget {
  final Post post;
  final bool isActive;
  final bool isTabActive;

  const _PostPage({
    required this.post,
    required this.isActive,
    required this.isTabActive,
  });

  @override
  State<_PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<_PostPage> {
  final List<Map<String, dynamic>> _hearts = [];

  void _handleDoubleTapDown(TapDownDetails details) {
    // Chúng ta chỉ kích hoạt animation khi đây là phát súng double tap.
    // Lưu ý: GestureDetector.onDoubleTapDown trigger khi phát hiện double tap.
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    setState(() {
      _hearts.add({
        'id': id,
        'position': details.localPosition,
      });
    });

    if (!widget.post.isLiked) {
      context.read<FeedBloc>().add(FeedToggleLike(widget.post.id, widget.post.isLiked));
    }
  }

  void _removeHeart(String id) {
    setState(() {
      _hearts.removeWhere((h) => h['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(context),
          PostOverlay(post: widget.post),
          
          // Trái tim bay lên (TikTok style)
          ..._hearts.map((h) => _HeartAnimation(
                key: ValueKey(h['id']),
                position: h['position'],
                onFinished: () => _removeHeart(h['id']),
              )),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.post.mediaType) {
      case 'video':
        return _VideoContent(
          post: widget.post,
          isActive: widget.isActive,
          isTabActive: widget.isTabActive,
        );
      case 'image':
        return _ImageContent(post: widget.post);
      default:
        return _TextContent(post: widget.post);
    }
  }
}

/// Video content — autoplay khi active, pause khi rời
class _VideoContent extends StatefulWidget {
  final Post post;
  final bool isActive;
  final bool isTabActive;

  const _VideoContent({
    required this.post,
    required this.isActive,
    required this.isTabActive,
  });

  @override
  State<_VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<_VideoContent> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(_VideoContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive || widget.isTabActive != oldWidget.isTabActive) {
      if (widget.isActive && widget.isTabActive) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  Future<void> _initVideo() async {
    if (widget.post.mediaUrls.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    final url = widget.post.mediaUrls.first;
    try {
      _controller = await FeedVideoManager().getOrCreateController(widget.post.id, url);
      if (mounted) {
        setState(() => _isInitialized = true);
        if (widget.isActive && widget.isTabActive) {
          _controller!.play();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    // Không dispose, do FeedVideoManager điều khiển vòng đời controller
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppTheme.bgCreamDarker,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppTheme.textSecondary.withValues(alpha: 128), size: 48),
              const SizedBox(height: 8),
              Text('Không thể phát video', style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      if (widget.post.thumbnailUrl != null && widget.post.thumbnailUrl!.isNotEmpty) {
        return Container(
          color: const Color(0xFF1A1208),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.post.thumbnailUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2),
                ),
              ),
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2),
              ),
            ],
          ),
        );
      }
      return Container(
        color: AppTheme.bgCream,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: const Color(0xFF1A1208), // Dark warm for video background
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),

            // Nút mute
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary.withValues(alpha: 100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Play icon khi pause
            if (!_controller!.value.isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary.withValues(alpha: 100),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                ),
              ),

            // Progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppTheme.primaryGold,
                  bufferedColor: Color(0x44CBA052),
                  backgroundColor: Color(0x22CBA052),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image content — giữ nguyên tỉ lệ ảnh, không zoom
class _ImageContent extends StatelessWidget {
  final Post post;

  const _ImageContent({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgCream,
      child: post.mediaUrls.isNotEmpty
          ? Center(
              child: CachedNetworkImage(
                imageUrl: post.mediaUrls.first,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.broken_image, color: AppTheme.textSecondary.withValues(alpha: 128), size: 64),
                ),
              ),
            )
          : Center(
              child: Icon(Icons.image, color: AppTheme.textSecondary.withValues(alpha: 128), size: 64),
            ),
    );
  }
}

/// Text-only content — premium card design dùng theme colors
class _TextContent extends StatelessWidget {
  final Post post;

  const _TextContent({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF8F5), // bgCream
            Color(0xFFF3EEDC), // bgCream variant
            Color(0xFFE8DFC8), // Kem đậm hơn
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 80, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.title != null && post.title!.isNotEmpty) ...[
              Text(
                post.title!,
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (post.content != null && post.content!.isNotEmpty)
              Text(
                post.content!,
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  height: 1.6,
                ),
                maxLines: 12,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiệu ứng trái tim bay lên khi double tap (TikTok style)
class _HeartAnimation extends StatefulWidget {
  final Offset position;
  final VoidCallback onFinished;

  const _HeartAnimation({
    super.key,
    required this.position,
    required this.onFinished,
  });

  @override
  State<_HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<_HeartAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.6), weight: 40),
    ]).animate(_controller);

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);

    // Random góc xoay nhẹ cho tự nhiên
    final randomRotation = (DateTime.now().millisecond % 40 - 20) * 0.01;
    _rotation = Tween<double>(begin: randomRotation, end: randomRotation * 2).animate(_controller);

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 60,
      top: widget.position.dy - 60,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shadow/Glow nhạt bên dưới
                    Icon(
                      Icons.favorite,
                      color: Colors.black.withValues(alpha: 51),
                      size: 110,
                    ),
                    // Trái tim chính
                    const ShaderMask(
                      shaderCallback: _createGradient,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Shader _createGradient(Rect bounds) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE52D27), // Đỏ đậm rực rỡ
        Color(0xFFF0610E), // Cam đậm rực rỡ
      ],
    ).createShader(bounds);
  }
}
