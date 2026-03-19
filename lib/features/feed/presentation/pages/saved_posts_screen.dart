import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../pages/feed_screen.dart';

/// Màn hình hiển thị danh sách bài đăng đã lưu (Bookmark)
class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = GetIt.instance<PostRepository>();
    final result = await repo.getSavedPosts(limit: 50);
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (posts) => setState(() {
        _posts = posts;
        _isLoading = false;
      }),
    );
  }

  void _openFeed(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedScreen(
          isTabActive: false,
          initialPosts: _posts,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài viết đã lưu',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppTheme.bgCream,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('Không thể tải dữ liệu', style: GoogleFonts.nunito(fontSize: 16, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadSavedPosts,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết nào được lưu',
              style: GoogleFonts.nunito(fontSize: 16, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn biểu tượng bookmark trên bài viết để lưu',
              style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.75,
        ),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _SavedPostTile(
            post: post,
            onTap: () => _openFeed(index),
          );
        },
      ),
    );
  }
}

class _SavedPostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _SavedPostTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnail(),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
            // Media type icon
            Positioned(
              top: 6,
              right: 6,
              child: Icon(
                post.mediaType == 'video'
                    ? Icons.play_circle_outline
                    : post.mediaType == 'image'
                        ? Icons.image_outlined
                        : Icons.article_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            // Title at bottom
            if (post.title != null && post.title!.isNotEmpty)
              Positioned(
                bottom: 4,
                left: 6,
                right: 6,
                child: Text(
                  post.title!,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    // Video thumbnail
    if (post.mediaType == 'video') {
      if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: post.thumbnailUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppTheme.bgCreamDarker),
          errorWidget: (_, __, ___) => _fallbackTile(),
        );
      }
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.videocam_outlined, color: Colors.white54, size: 32),
        ),
      );
    }
    // Image post
    if (post.mediaType == 'image' && post.mediaUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: post.mediaUrls.first,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppTheme.bgCreamDarker),
        errorWidget: (_, __, ___) => _fallbackTile(),
      );
    }
    // Text post
    return _fallbackTile();
  }

  Widget _fallbackTile() {
    return Container(
      color: AppTheme.bgCreamDarker,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            post.content ?? post.title ?? '',
            style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textPrimary),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
