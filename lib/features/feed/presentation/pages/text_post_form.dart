import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';

/// Form đăng bài Text / Ảnh
class TextPostForm extends StatefulWidget {
  const TextPostForm({super.key});

  @override
  State<TextPostForm> createState() => _TextPostFormState();
}

class _TextPostFormState extends State<TextPostForm> {
  final _contentController = TextEditingController();
  final _hashtagController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  final List<String> _hashtags = [];

  @override
  void dispose() {
    _contentController.dispose();
    _hashtagController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatePostBloc, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng bài thành công! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          // Pop cả 2 màn (form + chọn loại)
          Navigator.of(context)..pop()..pop();
        } else if (state is CreatePostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isUploading = state is CreatePostUploading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Bài viết'),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => _submit(context),
                child: Text(
                  'Đăng',
                  style: TextStyle(
                    color: isUploading ? AppTheme.textSecondary : AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Nội dung
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Bạn đang nghĩ gì...?',
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 128)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.dividerColor),
                        ),
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

                    // Ảnh đã chọn
                    if (state is CreatePostEditing && state.selectedFiles.isNotEmpty) ...[
                      Text('Ảnh đính kèm', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.selectedFiles.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.selectedFiles.length) {
                              // Nút thêm ảnh
                              return _AddImageButton(onTap: () => _pickImages(context));
                            }
                            return _ImagePreview(
                              file: state.selectedFiles[index],
                              onRemove: () => context.read<CreatePostBloc>().add(RemoveMedia(index)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Nút thêm ảnh (khi chưa có ảnh nào)
                    if (state is CreatePostEditing && state.selectedFiles.isEmpty)
                      OutlinedButton.icon(
                        onPressed: () => _pickImages(context),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Thêm ảnh'),
                      ),
                    const SizedBox(height: 20),

                    // Hashtags
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

              // Upload progress overlay
              if (state is CreatePostUploading) _UploadOverlay(state: state),
            ],
          ),
        );
      },
    );
  }

  void _pickImages(BuildContext context) async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      final files = images.map((x) => File(x.path)).toList();
      if (context.mounted) {
        // Khi chọn ảnh, chuyển mediaType sang 'image'
        final bloc = context.read<CreatePostBloc>();
        bloc.add(const SelectPostType('image'));
        bloc.add(SelectMedia(files));
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
    final content = _contentController.text.trim();
    final currentState = context.read<CreatePostBloc>().state;

    // Validate: cần content hoặc ảnh
    if (content.isEmpty && (currentState is CreatePostEditing && currentState.selectedFiles.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc thêm ảnh')),
      );
      return;
    }

    context.read<CreatePostBloc>().add(SubmitPost(
      content: content.isNotEmpty ? content : null,
      hashtags: _hashtags,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
    ));
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImagePreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file, width: 120, height: 120, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor, width: 2),
          color: AppTheme.bgCreamDarker,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: AppTheme.textSecondary, size: 32),
            SizedBox(height: 4),
            Text('Thêm ảnh', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _UploadOverlay extends StatelessWidget {
  final CreatePostUploading state;

  const _UploadOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryGold),
              const SizedBox(height: 16),
              Text(state.statusMessage, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: state.progress,
                backgroundColor: AppTheme.bgCreamDarker,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGold),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(state.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
