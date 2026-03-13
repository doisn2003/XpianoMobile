import 'package:equatable/equatable.dart';

import 'conversation.dart';

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String messageType;
  final String? mediaUrl;
  final String? replyToId;
  final bool isDeleted;
  final String createdAt;
  final ChatUser? author;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.replyToId,
    this.isDeleted = false,
    required this.createdAt,
    this.author,
  });

  @override
  List<Object?> get props => [id, conversationId, senderId, content, createdAt, isDeleted];
}
