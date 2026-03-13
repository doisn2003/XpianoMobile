import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/chat_repository.dart';
import '../bloc/chat_room_bloc.dart';
import '../bloc/chat_room_event.dart';
import '../bloc/chat_room_state.dart';
import '../widgets/message_bubble.dart';

class ChatRoomScreen extends StatelessWidget {
  final String conversationId;
  final String displayName;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatRoomBloc>(
      create: (_) => ChatRoomBloc(chatRepository: di.sl<ChatRepository>())..add(LoadMessages(conversationId)),
      child: _ChatRoomView(conversationId: conversationId, displayName: displayName),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final String conversationId;
  final String displayName;

  const _ChatRoomView({required this.conversationId, required this.displayName});

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String? get _currentUserId {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.id.toString();
    return null;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatRoomBloc>().add(SendMessageEvent(
      conversationId: widget.conversationId,
      content: text,
    ));
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        title: Text(
          widget.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
              builder: (context, state) {
                if (state is ChatRoomLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
                }

                if (state is ChatRoomError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(state.message, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ChatRoomBloc>().add(LoadMessages(widget.conversationId)),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ChatRoomLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('Bắt đầu cuộc trò chuyện!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return MessageBubble(
                        message: msg,
                        isMe: isMe,
                        onLongPress: isMe
                            ? () => _showDeleteDialog(context, msg.id)
                            : null,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 8, 8 + MediaQuery.of(context).viewPadding.bottom),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, -1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<ChatRoomBloc, ChatRoomState>(
            builder: (context, state) {
              final isSending = state is ChatRoomLoaded && state.isSending;
              return GestureDetector(
                onTap: isSending ? null : _sendMessage,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa tin nhắn?'),
        content: const Text('Tin nhắn sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatRoomBloc>().add(DeleteMessageEvent(messageId));
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
