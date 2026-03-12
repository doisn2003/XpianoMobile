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

/// Trang hồ sơ công khai của người dùng.
/// Tabs: Thông tin | Bài đăng
class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String? initialName;
  final String? initialAvatarUrl;
  final String? initialRole;

  const UserProfileScreen({
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
      child: _UserProfileBody(
        initialName: initialName,
        initialAvatarUrl: initialAvatarUrl,
        initialRole: initialRole,
      ),
    );
  }
}

class _UserProfileBody extends StatelessWidget {
  final String? initialName;
  final String? initialAvatarUrl;
  final String? initialRole;

  const _UserProfileBody({
    this.initialName,
    this.initialAvatarUrl,
    this.initialRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(initialName ?? 'Hồ sơ', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
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
              initialAvatarUrl: initialAvatarUrl,
              initialRole: initialRole,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final UserProfileLoaded state;
  final String? initialAvatarUrl;
  final String? initialRole;

  const _ProfileContent({
    required this.state,
    this.initialAvatarUrl,
    this.initialRole,
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
    final profileInfo = profileData['profile'] as Map<String, dynamic>? ?? {};
    final stats = profileData['stats'] as Map<String, dynamic>? ?? {};
    final isTeacher = profileData['isTeacher'] == true;

    final fullName = profileInfo['full_name'] ?? '';
    final avatarUrl = profileInfo['avatar_url'] ?? widget.initialAvatarUrl;
    final role = profileInfo['role'] ?? widget.initialRole ?? 'user';
    final followersCount = stats['followers_count'] ?? 0;
    final followingCount = stats['following_count'] ?? 0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Avatar lớn
                  UserAvatarWidget(
                    avatarUrl: avatarUrl,
                    fullName: fullName,
                    role: role,
                    radius: 44,
                  ),
                  const SizedBox(height: 12),

                  // Tên
                  Text(
                    fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role badge
                  if (isTeacher)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Giáo viên',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Followers / Following stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatColumn(count: followersCount, label: 'Followers'),
                      const SizedBox(width: 40),
                      _StatColumn(count: followingCount, label: 'Following'),
                      const SizedBox(width: 40),
                      _StatColumn(count: widget.state.posts.length, label: 'Bài viết'),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
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
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _InfoTab(profileData: profileData),
          _PostsTab(state: widget.state),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(count),
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Tab thông tin cơ bản
class _InfoTab extends StatelessWidget {
  final Map<String, dynamic> profileData;
  const _InfoTab({required this.profileData});

  @override
  Widget build(BuildContext context) {
    final profileInfo = profileData['profile'] as Map<String, dynamic>? ?? {};
    final stats = profileData['stats'] as Map<String, dynamic>? ?? {};
    final isTeacher = profileData['isTeacher'] == true;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          icon: Icons.person_outline,
          title: 'Tên',
          value: profileInfo['full_name'] ?? 'Chưa cập nhật',
        ),
        _InfoCard(
          icon: Icons.badge_outlined,
          title: 'Loại tài khoản',
          value: isTeacher ? 'Giáo viên (GV)' : 'Người dùng',
        ),
        _InfoCard(
          icon: Icons.people_outline,
          title: 'Người theo dõi',
          value: '${stats['followers_count'] ?? 0}',
        ),
        _InfoCard(
          icon: Icons.person_add_outlined,
          title: 'Đang theo dõi',
          value: '${stats['following_count'] ?? 0}',
        ),
        if (isTeacher && stats['courses_count'] != null)
          _InfoCard(
            icon: Icons.school_outlined,
            title: 'Số khóa học',
            value: '${stats['courses_count']}',
          ),
        if (isTeacher && stats['total_students'] != null)
          _InfoCard(
            icon: Icons.groups_outlined,
            title: 'Tổng học viên',
            value: '${stats['total_students']}',
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 22),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

/// Tab bài đăng
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

/// Card hiển thị bài viết đơn giản trong profile
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

/// Custom SliverPersistentHeaderDelegate cho TabBar
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
