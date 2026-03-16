import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';

/// Shared widget showing a course thumbnail with an optional Play button overlay.
/// Tapping Play loads and plays the demo video inline from Supabase Storage.
class CourseMediaHeader extends StatefulWidget {
  final String? thumbnailUrl;
  final String? coverUrl;
  final String? demoVideoUrl;
  final double height;

  const CourseMediaHeader({
    super.key,
    this.thumbnailUrl,
    this.coverUrl,
    this.demoVideoUrl,
    this.height = 240,
  });

  @override
  State<CourseMediaHeader> createState() => _CourseMediaHeaderState();
}

class _CourseMediaHeaderState extends State<CourseMediaHeader> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitializing = false;
  bool _hasError = false;

  String get _resolvedThumbnail => ImageUtils.optimizedCourseHero(
        widget.coverUrl ?? widget.thumbnailUrl,
      );

  String get _resolvedVideo => ImageUtils.resolveCourseVideo(widget.demoVideoUrl);

  bool get _hasVideo => widget.demoVideoUrl != null && widget.demoVideoUrl!.isNotEmpty;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPlayPressed() {
    if (_isInitializing) return;
    final videoUrl = _resolvedVideo;
    if (videoUrl.isEmpty) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _isPlaying = true;
          });
          _controller!.setLooping(true);
          _controller!.play();
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _hasError = true;
          });
        }
      });
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
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
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: _isPlaying && _controller != null && _controller!.value.isInitialized
          ? _buildVideoPlayer()
          : _buildThumbnailWithPlay(),
    );
  }

  Widget _buildThumbnailWithPlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail
        if (_resolvedThumbnail.isNotEmpty)
          CachedNetworkImage(
            imageUrl: _resolvedThumbnail,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildPlaceholder(),
            errorWidget: (_, __, ___) => _buildPlaceholder(),
          )
        else
          _buildPlaceholder(),

        // Play button overlay
        if (_hasVideo)
          Center(
            child: _isInitializing
                ? Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _onPlayPressed,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),

        // Error overlay
        if (_hasError)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Không thể tải video',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),

            // Pause overlay (shows briefly when paused)
            if (!_controller!.value.isPlaying)
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, size: 36, color: Colors.white),
                ),
              ),

            // Progress bar at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppTheme.primaryGold,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.bgCreamDarker,
      child: Center(
        child: Icon(Icons.school, size: 80, color: AppTheme.textSecondary.withOpacity(0.2)),
      ),
    );
  }
}
