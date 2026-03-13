abstract class ConversationListEvent {}

class LoadConversations extends ConversationListEvent {}

class CreateNewConversation extends ConversationListEvent {
  final String userId;
  CreateNewConversation({required this.userId});
}
