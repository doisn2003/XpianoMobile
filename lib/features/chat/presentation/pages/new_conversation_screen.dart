import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/user_search_data_source.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_room_screen.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final _searchController = TextEditingController();
  final _userSearchDataSource = di.sl<UserSearchDataSource>();
  final _chatRepository = di.sl<ChatRepository>();

  List<SearchedUser> _results = [];
  bool _isSearching = false;
  bool _isCreating = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final users = await _userSearchDataSource.searchUsers(query);
      if (mounted) {
        setState(() {
          _results = users;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _error = 'Lỗi tìm kiếm: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _startConversation(SearchedUser user) async {
    setState(() => _isCreating = true);

    final result = await _chatRepository.createConversation(userId: user.id);

    if (!mounted) return;
    setState(() => _isCreating = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (conversation) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              conversationId: conversation.id,
              displayName: conversation.displayName,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        title: const Text('Cuộc trò chuyện mới', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Search input
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tên, số điện thoại, email...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isCreating)
            Container(
              color: AppTheme.bgCream,
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Đang tạo cuộc trò chuyện...', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),

          // Results
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    if (_searchController.text.trim().length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text(
              'Nhập ít nhất 2 ký tự để tìm kiếm',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Không tìm thấy người dùng', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, color: AppTheme.dividerColor),
      itemBuilder: (context, index) => _buildUserTile(_results[index]),
    );
  }

  Widget _buildUserTile(SearchedUser user) {
    final avatarUrl = ImageUtils.optimizedAvatar(user.avatarUrl);
    final initial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';
    final subtitle = user.email ?? user.phone ?? '';

    return InkWell(
      onTap: _isCreating ? null : () => _startConversation(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
              backgroundImage: avatarUrl.isNotEmpty ? CachedNetworkImageProvider(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Text(initial, style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold, fontSize: 18))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                ],
              ),
            ),
            if (user.role == 'teacher')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('GV', style: TextStyle(fontSize: 11, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}
