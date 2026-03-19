import 'package:equatable/equatable.dart';

/// Author info hiển thị trên feed (ảnh, tên, role)
class PostAuthor extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String role;

  const PostAuthor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.role = 'user',
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, role];
}

/// Post entity — đại diện cho 1 bài viết trên feed
class Post extends Equatable {
  final String id;
  final String userId;
  final String? content;
  final String? title;
  final List<String> mediaUrls;
  final String mediaType; // 'none', 'image', 'video', 'mixed'
  final String postType;  // 'general', 'course_review', 'performance', 'tip'
  final List<String> hashtags;
  final String? location;
  final String? thumbnailUrl;
  final int? duration; // seconds (for video)
  final String? relatedCourseId;
  final int? relatedPianoId;
  final String visibility;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isPinned;
  final bool isLiked;
  final bool isSaved;
  final PostAuthor? author;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.userId,
    this.content,
    this.title,
    this.mediaUrls = const [],
    this.mediaType = 'none',
    this.postType = 'general',
    this.hashtags = const [],
    this.location,
    this.thumbnailUrl,
    this.duration,
    this.relatedCourseId,
    this.relatedPianoId,
    this.visibility = 'public',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isPinned = false,
    this.isLiked = false,
    this.isSaved = false,
    this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id, userId, content, title, mediaUrls, mediaType, postType,
        hashtags, location, thumbnailUrl, duration, relatedCourseId,
        relatedPianoId, visibility, likesCount, commentsCount,
        sharesCount, viewsCount, isPinned, isLiked, isSaved, author,
        createdAt, updatedAt,
      ];
}
