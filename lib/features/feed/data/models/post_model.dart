import '../../domain/entities/post.dart';

class PostAuthorModel extends PostAuthor {
  const PostAuthorModel({
    required super.id,
    required super.fullName,
    super.avatarUrl,
    super.role,
  });

  factory PostAuthorModel.fromJson(Map<String, dynamic> json) {
    return PostAuthorModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? 'Unknown',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      role: json['role'] ?? 'user',
    );
  }
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    super.content,
    super.title,
    super.mediaUrls,
    super.mediaType,
    super.postType,
    super.hashtags,
    super.location,
    super.thumbnailUrl,
    super.duration,
    super.relatedCourseId,
    super.relatedPianoId,
    super.visibility,
    super.likesCount,
    super.commentsCount,
    super.sharesCount,
    super.viewsCount,
    super.isPinned,
    super.isLiked,
    super.author,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Xử lý dual JSON: Supabase trả snake_case, Express trả camelCase
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse media_urls
    List<String> mediaUrls = [];
    final rawUrls = json['media_urls'] ?? json['mediaUrls'];
    if (rawUrls is List) {
      mediaUrls = rawUrls.map((e) => e.toString()).toList();
    }

    // Parse hashtags
    List<String> hashtags = [];
    final rawTags = json['hashtags'];
    if (rawTags is List) {
      hashtags = rawTags.map((e) => e.toString()).toList();
    }

    // Parse author
    PostAuthorModel? author;
    if (json['author'] is Map<String, dynamic>) {
      author = PostAuthorModel.fromJson(json['author']);
    }

    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      content: json['content'],
      title: json['title'],
      mediaUrls: mediaUrls,
      mediaType: json['media_type'] ?? json['mediaType'] ?? 'none',
      postType: json['post_type'] ?? json['postType'] ?? 'general',
      hashtags: hashtags,
      location: json['location'],
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      duration: _parseInt(json['duration']),
      relatedCourseId: json['related_course_id'] ?? json['relatedCourseId'],
      relatedPianoId: _parseIntNullable(json['related_piano_id'] ?? json['relatedPianoId']),
      visibility: json['visibility'] ?? 'public',
      likesCount: _parseIntDefault(json['likes_count'] ?? json['likesCount']),
      commentsCount: _parseIntDefault(json['comments_count'] ?? json['commentsCount']),
      sharesCount: _parseIntDefault(json['shares_count'] ?? json['sharesCount']),
      viewsCount: _parseIntDefault(json['views_count'] ?? json['viewsCount']),
      isPinned: json['is_pinned'] ?? json['isPinned'] ?? false,
      isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
      author: author,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'title': title,
      'media_urls': mediaUrls,
      'media_type': mediaType,
      'post_type': postType,
      'hashtags': hashtags,
      'location': location,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'related_course_id': relatedCourseId,
      'related_piano_id': relatedPianoId,
      'visibility': visibility,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static int _parseIntDefault(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
