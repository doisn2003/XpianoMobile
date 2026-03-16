import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'conversation_model.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    super.content,
    super.messageType,
    super.mediaUrl,
    super.replyToId,
    super.isDeleted,
    required super.createdAt,
    super.author,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    ChatUser? author;
    if (json['author'] != null && json['author'] is Map<String, dynamic>) {
      author = ChatUserModel.fromJson(json['author']);
    }

    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      replyToId: json['reply_to_id']?.toString(),
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      author: author,
    );
  }
}
