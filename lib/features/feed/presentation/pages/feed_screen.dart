import 'dart:async';
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
import '../widgets/post_overlay.dart';

/// Feed Screen — TikTok-style vuốt dọc full-screen
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedBloc(
        postRepository: GetIt.instance<PostRepository>(),
      )..add(FeedLoadRequested()),
      child: const _FeedBody(),
    );
  }
}

class _FeedBody extends StatefulWidget {
  const _FeedBody();

  @override
  State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final PageController _pageController = PageController();
  Timer? _viewTimer;
  int _currentPage = 0;

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
      context.read<FeedBloc>().add(FeedLoadMore());
    }
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
                  Text('Không thể tải feed', style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
                  )),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<FeedBloc>().add(FeedLoadRequested()),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is FeedLoaded) {
          if (state.posts.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note_outlined, size: 80, color: AppTheme.primaryGold.withValues(alpha: 77)),
                    const SizedBox(height: 16),
                    Text('Chưa có bài viết nào', style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
                    )),
                    const SizedBox(height: 8),
                    Text('Hãy là người đầu tiên chia sẻ!', style: GoogleFonts.outfit(
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
class _PostPage extends StatelessWidget {
  final Post post;
  final bool isActive;

  const _PostPage({required this.post, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildContent(context),
        PostOverlay(post: post),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (post.mediaType) {
      case 'video':
        return _VideoContent(post: post, isActive: isActive);
      case 'image':
        return _ImageContent(post: post);
      default:
        return _TextContent(post: post);
    }
  }
}

/// Video content — autoplay khi active, pause khi rời
class _VideoContent extends StatefulWidget {
  final Post post;
  final bool isActive;

  const _VideoContent({required this.post, required this.isActive});

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
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  void _initVideo() {
    if (widget.post.mediaUrls.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    final url = widget.post.mediaUrls.first;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller!.setLooping(true);
          if (widget.isActive) {
            _controller!.play();
          }
        }
      }).catchError((e) {
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
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
              Text('Không thể phát video', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
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
              child: Image.network(
                post.mediaUrls.first,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryGold),
                  );
                },
                errorBuilder: (_, __, ___) => Center(
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
                style: GoogleFonts.outfit(
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
                style: GoogleFonts.outfit(
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
