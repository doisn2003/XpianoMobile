import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';
import 'text_post_form.dart';
import 'video_post_form.dart';

/// Màn hình chọn loại bài viết — mở từ nút "+" trên navbar
/// Sử dụng global CreatePostBloc (không tạo BlocProvider mới)
class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ reset khi KHÔNG đang upload (tránh mất trạng thái upload đang chạy)
    final state = context.read<CreatePostBloc>().state;
    if (state is! CreatePostUploading) {
      context.read<CreatePostBloc>().add(ResetCreatePost());
    }

    return const _CreatePostBody();
  }
}

class _CreatePostBody extends StatelessWidget {
  const _CreatePostBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Chọn cách bạn muốn chia sẻ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Chia sẻ khoảnh khắc Piano của bạn với cộng đồng',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            
            const SizedBox(height: 20),
            const SizedBox(height: 16),
            _PostTypeCard(
              icon: Icons.videocam_rounded,
              title: 'Video',
              subtitle: 'Quay hoặc tải video biểu diễn piano',
              onTap: () => _navigateToForm(context, 'video'),
            ),
            const SizedBox(height: 20),
            _PostTypeCard(
              icon: Icons.text_fields_rounded,
              title: 'Bài viết Text / Ảnh',
              subtitle: 'Chia sẻ suy nghĩ, kinh nghiệm hoặc hình ảnh',
              onTap: () => _navigateToForm(context, 'text'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String type) {
    final bloc = context.read<CreatePostBloc>();

    if (type == 'video') {
      bloc.add(const SelectPostType('video'));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const VideoPostForm(),
          ),
        ),
      );
    } else {
      bloc.add(const SelectPostType('none'));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const TextPostForm(),
          ),
        ),
      );
    }
  }
}

class _PostTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PostTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
