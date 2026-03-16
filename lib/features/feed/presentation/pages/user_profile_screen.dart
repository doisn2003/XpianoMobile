import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar_widget.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';

void showUserProfileBottomSheet(
  BuildContext context, {
  required String userId,
  String? initialName,
  String? initialAvatarUrl,
  String? initialRole,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => UserProfileBottomSheet(
      userId: userId,
      initialName: initialName,
      initialAvatarUrl: initialAvatarUrl,
      initialRole: initialRole,
    ),
  );
}

class UserProfileBottomSheet extends StatelessWidget {
  final String userId;
  final String? initialName;
  final String? initialAvatarUrl;
  final String? initialRole;

  const UserProfileBottomSheet({
    super.key,
    required this.userId,
    this.initialName,
    this.initialAvatarUrl,
    this.initialRole,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserProfileBloc(
        postRepository: GetIt.instance<PostRepository>(),
      )..add(UserProfileLoadRequested(userId)),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              bottom: true,
              child: Column(
                children: [
                  // Modal grabber
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _UserProfileBody(
                      initialName: initialName,
                      initialAvatarUrl: initialAvatarUrl,
                      initialRole: initialRole,
                      scrollController: scrollController,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserProfileBody extends StatelessWidget {
  final String? initialName;
  final String? initialAvatarUrl;
  final String? initialRole;
  final ScrollController scrollController;

  const _UserProfileBody({
    this.initialName,
    this.initialAvatarUrl,
    this.initialRole,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
        }

        if (state is UserProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary.withValues(alpha: 128)),
                const SizedBox(height: 12),
                Text('Không thể tải hồ sơ', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(state.message, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        if (state is UserProfileLoaded) {
          return _ProfileContent(
            state: state,
            initialName: initialName,
            initialAvatarUrl: initialAvatarUrl,
            initialRole: initialRole,
            scrollController: scrollController,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final UserProfileLoaded state;
  final String? initialName;
  final String? initialAvatarUrl;
  final String? initialRole;
  final ScrollController scrollController;

  const _ProfileContent({
    required this.state,
    this.initialName,
    this.initialAvatarUrl,
    this.initialRole,
    required this.scrollController,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileData = widget.state.profile;
    final user = (profileData['user'] as Map<String, dynamic>?) ?? profileData;
    final stats = profileData['stats'] as Map<String, dynamic>? ?? user['stats'] as Map<String, dynamic>? ?? {};
    final isTeacher = user['role'] == 'teacher' || profileData['isTeacher'] == true;
    final isFollowing = profileData['is_following'] == true;

    final fullName = user['full_name'] ?? user['fullName'] ?? widget.initialName ?? '';
    final avatarUrl = user['avatar_url'] ?? user['avatar'] ?? widget.initialAvatarUrl;
    final role = user['role'] ?? widget.initialRole ?? 'user';
    final followersCount = stats['followers_count'] ?? 0;
    final followingCount = stats['following_count'] ?? 0;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Avatar
              UserAvatarWidget(
                avatarUrl: avatarUrl,
                fullName: fullName,
                role: role,
                radius: 38,
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                fullName,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatColumn(
                    count: followersCount, 
                    label: 'Followers',
                    isFollowing: isFollowing,
                    onFollowTap: () => context.read<UserProfileBloc>().add(UserProfileToggleFollow()),
                  ),
                  const SizedBox(width: 40),
                  _StatColumn(count: followingCount, label: 'Following'),
                  const SizedBox(width: 40),
                  _StatColumn(count: widget.state.posts.length, label: 'Bài viết'),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        
        // Custom Tab-like behavior inside ListView to maintain sync with DraggableScrollableSheet
        DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryGold,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryGold,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: 'Thông tin'),
                  Tab(text: 'Bài đăng'),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InfoTab(profileData: user),
                    _PostsTab(state: widget.state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  final bool? isFollowing;
  final VoidCallback? onFollowTap;

  const _StatColumn({
    required this.count, 
    required this.label,
    this.isFollowing,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatCount(count),
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            if (onFollowTap != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onFollowTap,
                child: Icon(
                  isFollowing == true ? Icons.person_remove_outlined : Icons.person_add_alt_1_outlined,
                  size: 18,
                  color: isFollowing == true ? AppTheme.textSecondary : AppTheme.primaryGold,
                ),
              ),
            ],
          ],
        ),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _InfoTab extends StatelessWidget {
  final Map<String, dynamic> profileData;
  const _InfoTab({required this.profileData});

  @override
  Widget build(BuildContext context) {
    // Hàm helper để tìm dữ liệu trong cả profileData và profileData['user'] hoặc profileData['profile']
    dynamic find(String key1, [String? key2]) {
      final user = profileData['user'] as Map<String, dynamic>? ?? {};
      final profile = profileData['profile'] as Map<String, dynamic>? ?? {};
      
      return profileData[key1] ?? profileData[key2] ?? 
             user[key1] ?? user[key2] ?? 
             profile[key1] ?? profile[key2];
    }

    final bio = find('bio')?.toString();
    final dateOfBirth = find('date_of_birth', 'dateOfBirth')?.toString();
    final occupation = find('occupation')?.toString();
    final school = find('school')?.toString();
    final location = find('location')?.toString();
    
    final hobbiesData = find('hobbies');
    final hobbies = hobbiesData is List ? hobbiesData.map((e) => e.toString()).toList() : [];
    
    final instrumentsData = find('instruments');
    final instruments = instrumentsData is List ? instrumentsData.map((e) => e.toString()).toList() : [];

    final hasAnyInfo = (bio != null && bio.isNotEmpty) || 
                       (dateOfBirth != null && dateOfBirth.isNotEmpty) || 
                       (occupation != null && occupation.isNotEmpty) || 
                       (school != null && school.isNotEmpty) || 
                       (location != null && location.isNotEmpty) || 
                       hobbies.isNotEmpty || instruments.isNotEmpty;

    if (!hasAnyInfo) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('Chưa có thông tin giới thiệu', 
              style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (bio != null && bio.isNotEmpty) ...[
          Text(
            bio,
            style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],

        // Basic Info Box
        if (dateOfBirth != null || occupation != null || school != null || location != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dateOfBirth != null && dateOfBirth.isNotEmpty)
                  _buildInfoRow(Icons.cake_outlined, 'Sinh nhật', _formatDate(dateOfBirth)),
                if (occupation != null && occupation.isNotEmpty)
                  _buildInfoRow(Icons.work_outline, 'Nghề nghiệp', occupation),
                if (school != null && school.isNotEmpty)
                  _buildInfoRow(Icons.school_outlined, 'Trường học', school),
                if (location != null && location.isNotEmpty)
                  _buildInfoRow(Icons.location_on_outlined, 'Nơi ở', location),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Hobbies
        if (hobbies.isNotEmpty) ...[
          Text('Sở thích', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hobbies.map((h) => _buildBadge(h, Icons.favorite_border)).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Instruments
        if (instruments.isNotEmpty) ...[
          Text('Nhạc cụ', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: instruments.map((i) => _buildBadge(i, Icons.music_note_outlined)).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
          Expanded(
            child: Text(value, style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCreamDarker,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGoldDark),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoString;
    }
  }
}

class _PostsTab extends StatelessWidget {
  final UserProfileLoaded state;
  const _PostsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: AppTheme.textSecondary.withValues(alpha: 100)),
            const SizedBox(height: 8),
            Text('Chưa có bài viết nào', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification && notification.metrics.extentAfter < 200) {
          context.read<UserProfileBloc>().add(UserProfileLoadMorePosts());
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: state.posts.length + (state.isLoadingMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
            );
          }
          return _PostCard(post: state.posts[index]);
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (post.title != null && post.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                post.title!,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Content
          if (post.content != null && post.content!.isNotEmpty)
            Text(
              post.content!,
              style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

          // Media preview
          if (post.mediaUrls.isNotEmpty && post.mediaType == 'image')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.mediaUrls.first,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, st) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Hashtags
          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                children: post.hashtags.take(4).map((tag) => Text(
                  '#$tag',
                  style: GoogleFonts.outfit(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.w500),
                )).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // Stats row
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red.shade300, size: 16),
              const SizedBox(width: 4),
              Text('${post.likesCount}', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(width: 14),
              Icon(Icons.chat_bubble_outline, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text('${post.commentsCount}', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(width: 14),
              Icon(Icons.visibility_outlined, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text('${post.viewsCount}', style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 12)),
              const Spacer(),
              Text(
                _timeAgo(post.createdAt),
                style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} năm trước';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppTheme.bgCream, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
