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
import 'new_conversation_screen.dart';

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

class _ConversationListView extends StatefulWidget {
  const _ConversationListView();

  @override
  State<_ConversationListView> createState() => _ConversationListViewState();
}

class _ConversationListViewState extends State<_ConversationListView> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: Column(
        children: [
          // Header with search
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: _isSearching
                      ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Tìm theo tên, tin nhắn...',
                            hintStyle: TextStyle(color: AppTheme.textSecondary),
                            border: InputBorder.none,
                          ),
                          onChanged: (query) {
                            context.read<ConversationListBloc>().add(SearchConversations(query));
                          },
                        )
                      : const Text(
                          'Tin nhắn',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                ),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppTheme.textPrimary),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        context.read<ConversationListBloc>().add(SearchConversations(''));
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // Conversation list
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
                  final conversations = state.filteredConversations;

                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            state.searchQuery.isNotEmpty
                                ? 'Không tìm thấy cuộc trò chuyện'
                                : 'Chưa có cuộc trò chuyện nào',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                          ),
                          if (state.searchQuery.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Nhấn + để bắt đầu trò chuyện mới',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ),
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
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, color: AppTheme.dividerColor),
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewConversationScreen()),
          );
        },
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
