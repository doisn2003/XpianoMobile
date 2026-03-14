abstract class ConversationListEvent {}

class LoadConversations extends ConversationListEvent {}

class SearchConversations extends ConversationListEvent {
  final String query;
  SearchConversations(this.query);
}

class CreateNewConversation extends ConversationListEvent {
  final String userId;
  CreateNewConversation({required this.userId});
}
