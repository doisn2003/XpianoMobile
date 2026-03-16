import '../../domain/entities/message.dart';

abstract class ChatRoomState {}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<Message> messages;
  final bool isSending;

  ChatRoomLoaded({required this.messages, this.isSending = false});

  ChatRoomLoaded copyWith({List<Message>? messages, bool? isSending}) {
    return ChatRoomLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatRoomError extends ChatRoomState {
  final String message;
  ChatRoomError(this.message);
}
