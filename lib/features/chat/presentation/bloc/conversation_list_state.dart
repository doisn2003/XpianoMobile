import '../../domain/entities/conversation.dart';

abstract class ConversationListState {}

class ConversationListInitial extends ConversationListState {}

class ConversationListLoading extends ConversationListState {}

class ConversationListLoaded extends ConversationListState {
  final List<Conversation> conversations;
  final List<Conversation> filteredConversations;
  final String searchQuery;

  ConversationListLoaded({
    required this.conversations,
    List<Conversation>? filteredConversations,
    this.searchQuery = '',
  }) : filteredConversations = filteredConversations ?? conversations;
}

class ConversationListError extends ConversationListState {
  final String message;
  ConversationListError(this.message);
}

class ConversationCreated extends ConversationListState {
  final Conversation conversation;
  ConversationCreated(this.conversation);
}
