import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../injection_container.dart';
import 'bloc/home_feed_bloc.dart';
import 'bloc/home_feed_event.dart';
import 'bloc/home_feed_state.dart';
import 'widgets/video_feed_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeFeedBloc>()..add(LoadFeedEvent()),
      child: const HomeFeedView(),
    );
  }
}

class HomeFeedView extends StatelessWidget {
  const HomeFeedView({super.key});

  Future<void> _pickMediaAndUpload(BuildContext context, bool isVideo) async {
    final picker = ImagePicker();
    final XFile? media = isVideo 
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);

    if (media != null && context.mounted) {
      context.read<HomeFeedBloc>().add(
        CreatePostEvent(
          content: 'Khởi đầu mới cùng Xpiano! 🎹✨',
          mediaFile: File(media.path),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang đăng bài...⏳')),
      );
    }
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tạo bài viết mới',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.white),
              title: const Text('Tải lên Video', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickMediaAndUpload(context, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Tải lên Hình ảnh', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickMediaAndUpload(context, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<HomeFeedBloc, HomeFeedState>(
        listener: (context, state) {
          if (state is HomeFeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is CreatePostLoading) {
            // Already handled via initial snackbar, or show a dialog
          }
        },
        builder: (context, state) {
          if (state is HomeFeedLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (state is HomeFeedLoaded || state is CreatePostLoading) {
            final posts = state is HomeFeedLoaded 
                ? state.posts 
                : (state as CreatePostLoading).previousPosts;

            if (posts.isEmpty) {
              return const Center(
                child: Text('Chưa có bài viết nào.', style: TextStyle(color: Colors.white)),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeFeedBloc>().add(LoadFeedEvent());
              },
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return VideoFeedItem(post: posts[index]);
                },
              ),
            );
          } else if (state is HomeFeedError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeFeedBloc>().add(LoadFeedEvent()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
