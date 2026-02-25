import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../data/models/post_model.dart';
import '../bloc/home_feed_bloc.dart';
import '../bloc/home_feed_event.dart';

class VideoFeedItem extends StatefulWidget {
  final PostModel post;

  const VideoFeedItem({super.key, required this.post});

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == 'video' && widget.post.mediaUrls.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrls.first))
        ..initialize().then((_) {
          _videoController!.setLooping(true);
          _videoController!.play();
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final String mediaUrl = post.mediaUrls.isNotEmpty 
        ? post.mediaUrls.first 
        : 'https://images.unsplash.com/photo-1552422535-c45813c61732'; // Fallback

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Video / Image
        if (post.mediaType == 'video' && _videoController != null && _videoController!.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          )
        else
          Image.network(
            mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
          ),
        // Dark Overlay for better text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.9), // Darker at the bottom
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // 2. Safe Area Content Overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TOP LEFT: Host info
                _buildTopHostInfo(),

                // BOTTOM PART: Right Icons & Bottom Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Bottom Left Detail (Title, Location, Audio, Action Buttons)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCaption(),
                          const SizedBox(height: 12),
                          _buildLocationChip(),
                          const SizedBox(height: 12),
                          _buildAudioTrack(),
                          const SizedBox(height: 20),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bottom Right (Actions: Like, Comment...)
                    _buildRightActions(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=5'),
            ),
            const SizedBox(width: 8),
            Text(
              widget.post.authorName ?? 'Người ẩn danh',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified, color: AppTheme.primaryGold, size: 16),
              SizedBox(width: 4),
              Text(
                'Trải nghiệm thật',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkOverlay, // Using dark overlay or tinted color
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=5'),
            ),
          ),
          const SizedBox(height: 24),

          // Like
          GestureDetector(
            onTap: () {
              context.read<HomeFeedBloc>().add(LikePostEvent(widget.post.id));
            },
            child: _buildActionItem(
              Icons.favorite, 
              widget.post.likesCount.toString(),
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 20),

          // Comment
          _buildActionItem(Icons.chat_bubble_outline, widget.post.commentsCount.toString()),
          const SizedBox(height: 20),

          // Bookmark
          _buildActionItem(Icons.bookmark_border, '89'),
          const SizedBox(height: 20),

          // Share
          const Icon(Icons.reply, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String text, {Color color = Colors.white}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCaption() {
    return Text(
      widget.post.content ?? 'Bài viết từ Xpiano!',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
        shadows: [
          Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEADB90).withValues(alpha: 0.9), // Light beige/gold
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: Colors.black87, size: 14),
          SizedBox(width: 4),
          Text(
            'Hà Nội',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTrack() {
    return Row(
      children: [
        const Icon(Icons.music_note, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(
          'Âm thanh gốc • @${widget.post.authorName ?? ''}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.piano, color: Colors.black87, size: 20),
            label: const Text(
              'Mượn Đàn',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryGold, AppTheme.primaryGold],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.school, color: Colors.black87, size: 20),
              label: const Text(
                'Học Ngay',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
