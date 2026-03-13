import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = conversation.otherUser?.avatarUrl;
    final name = conversation.displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    String timeStr = '';
    if (conversation.lastMessageAt != null) {
      final dt = DateTime.tryParse(conversation.lastMessageAt!);
      if (dt != null) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inDays == 0) {
          timeStr = DateFormat('HH:mm').format(dt);
        } else if (diff.inDays < 7) {
          timeStr = '${diff.inDays}d';
        } else {
          timeStr = DateFormat('dd/MM').format(dt);
        }
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? Text(initial, style: const TextStyle(color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold, fontSize: 18))
                  : null,
            ),
            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (conversation.lastMessageContent != null)
                    Text(
                      conversation.lastMessageContent!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: conversation.hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                        fontWeight: conversation.hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),

            // Time + unread dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                if (conversation.hasUnread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
