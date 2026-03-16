import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/chat_repository.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatRepository chatRepository;

  ChatRoomBloc({required this.chatRepository}) : super(ChatRoomInitial()) {
    on<LoadMessages>(_onLoad);
    on<SendMessageEvent>(_onSend);
    on<DeleteMessageEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadMessages event, Emitter<ChatRoomState> emit) async {
    emit(ChatRoomLoading());
    final result = await chatRepository.getMessages(event.conversationId);
    result.fold(
      (failure) => emit(ChatRoomError(failure.message)),
      (messages) => emit(ChatRoomLoaded(messages: messages)),
    );
  }

  Future<void> _onSend(SendMessageEvent event, Emitter<ChatRoomState> emit) async {
    final current = state;
    if (current is ChatRoomLoaded) {
      emit(current.copyWith(isSending: true));
    }

    final result = await chatRepository.sendMessage(event.conversationId, content: event.content);
    result.fold(
      (failure) {
        if (current is ChatRoomLoaded) {
          emit(current.copyWith(isSending: false));
        }
      },
      (message) {
        if (current is ChatRoomLoaded) {
          emit(ChatRoomLoaded(messages: [message, ...current.messages], isSending: false));
        }
      },
    );
  }

  Future<void> _onDelete(DeleteMessageEvent event, Emitter<ChatRoomState> emit) async {
    await chatRepository.deleteMessage(event.messageId);
    final current = state;
    if (current is ChatRoomLoaded) {
      final updated = current.messages.where((m) => m.id != event.messageId).toList();
      emit(ChatRoomLoaded(messages: updated));
    }
  }
}
