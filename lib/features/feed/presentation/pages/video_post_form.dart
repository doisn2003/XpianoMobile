import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';

/// Form đăng bài Video
/// Pop ngay lập tức sau khi submit — upload chạy nền, banner toàn cục hiển thị tiến độ.
class VideoPostForm extends StatefulWidget {
  const VideoPostForm({super.key});

  @override
  State<VideoPostForm> createState() => _VideoPostFormState();
}

class _VideoPostFormState extends State<VideoPostForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _hashtagController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  final List<String> _hashtags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _hashtagController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePostBloc, CreatePostState>(
      buildWhen: (prev, curr) => curr is CreatePostEditing,
      builder: (context, state) {
        File? videoFile;
        if (state is CreatePostEditing && state.selectedFiles.isNotEmpty) {
          videoFile = state.selectedFiles.first;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Đăng Video'),
            actions: [
              TextButton(
                onPressed: () => _submit(context),
                child: const Text(
                  'Đăng',
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video preview / picker
                  _VideoPickerSection(
                    videoFile: videoFile,
                    onPickVideo: () => _pickVideo(context),
                    onRemoveVideo: () {
                      context.read<CreatePostBloc>().add(const RemoveMedia(0));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tiêu đề
                  Text('Tiêu đề', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Tiêu đề video (tùy chọn)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                      ),
                      filled: true,
                      fillColor: AppTheme.cardWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nội dung / mô tả
                  Text('Mô tả', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Viết mô tả cho video...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                      ),
                      filled: true,
                      fillColor: AppTheme.cardWhite,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hashtag
                  Text('Hashtag', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hashtagController,
                          decoration: InputDecoration(
                            hintText: 'Nhập hashtag...',
                            prefixText: '#',
                            prefixStyle: const TextStyle(color: AppTheme.primaryGold),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.dividerColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addHashtag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addHashtag,
                        icon: const Icon(Icons.add, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_hashtags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _hashtags.map((tag) => Chip(
                        label: Text('#$tag', style: const TextStyle(fontSize: 13)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _hashtags.remove(tag)),
                        backgroundColor: AppTheme.bgCreamDarker,
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Vị trí
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Thêm vị trí (tùy chọn)',
                      prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryGold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickVideo(BuildContext context) async {
    final video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null && context.mounted) {
      final file = File(video.path);
      final fileSize = await file.length();

      // Kiểm tra giới hạn 50MB
      if (fileSize > 50 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video quá lớn! Giới hạn 50MB.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        context.read<CreatePostBloc>().add(SelectMedia([file]));
      }
    }
  }

  void _addHashtag() {
    final text = _hashtagController.text.trim().replaceAll('#', '');
    if (text.isNotEmpty && !_hashtags.contains(text.toLowerCase())) {
      setState(() {
        _hashtags.add(text.toLowerCase());
        _hashtagController.clear();
      });
    }
  }

  void _submit(BuildContext context) {
    final currentState = context.read<CreatePostBloc>().state;

    // Validate: cần video
    if (currentState is CreatePostEditing && currentState.selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn video')),
      );
      return;
    }

    // Submit — upload chạy nền
    context.read<CreatePostBloc>().add(SubmitPost(
      content: _contentController.text.trim().isNotEmpty ? _contentController.text.trim() : null,
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
      hashtags: _hashtags,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      postType: 'performance',
    ));

    // Pop ngay — quay về CreatePostScreen (user có thể đăng tiếp hoặc thoát ra)
    Navigator.of(context).pop();
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _VideoPickerSection extends StatelessWidget {
  final File? videoFile;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  const _VideoPickerSection({
    required this.videoFile,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    if (videoFile != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCreamDarker,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.videocam, color: AppTheme.primaryGold, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoFile!.path.split(Platform.pathSeparator).last,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FutureBuilder<int>(
                    future: videoFile!.length(),
                    builder: (_, snapshot) => Text(
                      snapshot.hasData
                          ? '${(snapshot.data! / (1024 * 1024)).toStringAsFixed(1)} MB'
                          : '...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemoveVideo,
              icon: const Icon(Icons.close, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    // Placeholder: chọn video
    return GestureDetector(
      onTap: onPickVideo,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.bgCreamDarker,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor, width: 2, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.video_library_outlined, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn video từ thư viện',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Tối đa 50MB • MP4, MOV',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
