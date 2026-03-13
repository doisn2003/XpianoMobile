import 'package:equatable/equatable.dart';

class ChatUser extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? role;

  const ChatUser({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.role,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, role];
}

class Conversation extends Equatable {
  final String id;
  final String type;
  final String? name;
  final String? lastMessageAt;
  final String? lastMessageContent;
  final ChatUser? otherUser;
  final bool hasUnread;
  final bool isMuted;
  final String? createdBy;

  const Conversation({
    required this.id,
    this.type = 'direct',
    this.name,
    this.lastMessageAt,
    this.lastMessageContent,
    this.otherUser,
    this.hasUnread = false,
    this.isMuted = false,
    this.createdBy,
  });

  String get displayName {
    if (type == 'direct' && otherUser != null) return otherUser!.fullName;
    return name ?? 'Nhóm chat';
  }

  @override
  List<Object?> get props => [id, type, name, lastMessageAt, otherUser, hasUnread];
}
