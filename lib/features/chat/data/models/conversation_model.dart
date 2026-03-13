import '../../domain/entities/conversation.dart';

class ChatUserModel extends ChatUser {
  const ChatUserModel({
    required super.id,
    required super.fullName,
    super.avatarUrl,
    super.role,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
    );
  }
}

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    super.type,
    super.name,
    super.lastMessageAt,
    super.lastMessageContent,
    super.otherUser,
    super.hasUnread,
    super.isMuted,
    super.createdBy,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    ChatUser? otherUser;
    if (json['other_user'] != null && json['other_user'] is Map<String, dynamic>) {
      otherUser = ChatUserModel.fromJson(json['other_user']);
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'direct',
      name: json['name'] as String?,
      lastMessageAt: json['last_message_at'] as String?,
      lastMessageContent: json['last_message_content'] as String?,
      otherUser: otherUser,
      hasUnread: json['has_unread'] as bool? ?? false,
      isMuted: json['is_muted'] as bool? ?? false,
      createdBy: json['created_by']?.toString(),
    );
  }
}
