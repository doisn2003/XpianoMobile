import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String userId;
  final String? content;
  final List<String> mediaUrls;
  final String mediaType;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  
  // Author info (nếu join được, nếu không thì rỗng trước)
  final String? authorName;
  final String? authorAvatar;

  const PostModel({
    required this.id,
    required this.userId,
    this.content,
    required this.mediaUrls,
    required this.mediaType,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.authorName,
    this.authorAvatar,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handling profiles join
    final profile = json['author'] ?? json['profiles'];
    String? authorName = profile != null ? profile['full_name'] : 'Unknown';
    String? authorAvatar = profile != null ? profile['avatar_url'] : null;

    // Handling media_urls which could be a String (if JSON encoded) or List
    List<String> parsedMediaUrls = [];
    if (json['media_urls'] != null) {
      if (json['media_urls'] is String) {
        // Just in case it's a string somehow
        parsedMediaUrls = [json['media_urls']];
      } else if (json['media_urls'] is List) {
        parsedMediaUrls = List<String>.from(json['media_urls']);
      }
    }

    return PostModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'],
      mediaUrls: parsedMediaUrls,
      mediaType: json['media_type'] ?? 'none',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      authorName: authorName,
      authorAvatar: authorAvatar,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, content, mediaUrls, mediaType, createdAt, 
        likesCount, commentsCount, authorName, authorAvatar
      ];
}
