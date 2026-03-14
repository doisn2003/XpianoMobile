import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/chat_repository.dart';
import 'conversation_list_event.dart';
import 'conversation_list_state.dart';

class ConversationListBloc extends Bloc<ConversationListEvent, ConversationListState> {
  final ChatRepository chatRepository;

  ConversationListBloc({required this.chatRepository}) : super(ConversationListInitial()) {
    on<LoadConversations>(_onLoad);
    on<SearchConversations>(_onSearch);
    on<CreateNewConversation>(_onCreate);
  }

  Future<void> _onLoad(LoadConversations event, Emitter<ConversationListState> emit) async {
    emit(ConversationListLoading());
    final result = await chatRepository.getConversations();
    result.fold(
      (failure) => emit(ConversationListError(failure.message)),
      (conversations) => emit(ConversationListLoaded(conversations: conversations)),
    );
  }

  void _onSearch(SearchConversations event, Emitter<ConversationListState> emit) {
    final current = state;
    if (current is! ConversationListLoaded) return;

    final query = event.query.trim().toLowerCase();
    if (query.isEmpty) {
      emit(ConversationListLoaded(
        conversations: current.conversations,
        searchQuery: '',
      ));
      return;
    }

    final filtered = current.conversations.where((c) {
      final name = c.displayName.toLowerCase();
      final lastMsg = (c.lastMessageContent ?? '').toLowerCase();
      return name.contains(query) || lastMsg.contains(query);
    }).toList();

    emit(ConversationListLoaded(
      conversations: current.conversations,
      filteredConversations: filtered,
      searchQuery: query,
    ));
  }

  Future<void> _onCreate(CreateNewConversation event, Emitter<ConversationListState> emit) async {
    final result = await chatRepository.createConversation(userId: event.userId);
    result.fold(
      (failure) => emit(ConversationListError(failure.message)),
      (conversation) {
        emit(ConversationCreated(conversation));
        add(LoadConversations());
      },
    );
  }
}
