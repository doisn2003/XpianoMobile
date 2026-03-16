abstract class ChatRoomEvent {}

class LoadMessages extends ChatRoomEvent {
  final String conversationId;
  LoadMessages(this.conversationId);
}

class SendMessageEvent extends ChatRoomEvent {
  final String conversationId;
  final String content;

  SendMessageEvent({required this.conversationId, required this.content});
}

class DeleteMessageEvent extends ChatRoomEvent {
  final String messageId;
  DeleteMessageEvent(this.messageId);
}
