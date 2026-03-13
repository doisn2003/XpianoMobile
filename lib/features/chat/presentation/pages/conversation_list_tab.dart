import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/repositories/chat_repository.dart';
import '../bloc/conversation_list_bloc.dart';
import '../bloc/conversation_list_event.dart';
import '../bloc/conversation_list_state.dart';
import '../widgets/conversation_tile.dart';
import 'chat_room_screen.dart';

class ConversationListTab extends StatelessWidget {
  const ConversationListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationListBloc>(
      create: (_) => ConversationListBloc(chatRepository: di.sl<ChatRepository>())..add(LoadConversations()),
      child: const _ConversationListView(),
    );
  }
}

class _ConversationListView extends StatelessWidget {
  const _ConversationListView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.cardWhite,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          width: double.infinity,
          child: const Text(
            'Tin nhắn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ),
        Expanded(
          child: BlocConsumer<ConversationListBloc, ConversationListState>(
            listener: (context, state) {
              if (state is ConversationCreated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                      conversationId: state.conversation.id,
                      displayName: state.conversation.displayName,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ConversationListLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
              }

              if (state is ConversationListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ConversationListBloc>().add(LoadConversations()),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ConversationListLoaded) {
                if (state.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('Chưa có cuộc trò chuyện nào', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Bắt đầu trò chuyện từ hồ sơ người dùng', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryGold,
                  onRefresh: () async {
                    context.read<ConversationListBloc>().add(LoadConversations());
                  },
                  child: ListView.separated(
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, color: AppTheme.dividerColor),
                    itemBuilder: (context, index) {
                      final conv = state.conversations[index];
                      return ConversationTile(
                        conversation: conv,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                conversationId: conv.id,
                                displayName: conv.displayName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
