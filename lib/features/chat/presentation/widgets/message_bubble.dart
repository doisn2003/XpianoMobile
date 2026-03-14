import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return _buildDeletedBubble();
    }

    final time = DateTime.tryParse(message.createdAt);
    final timeStr = time != null ? DateFormat('HH:mm').format(time) : '';

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _buildAvatar(),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primaryGold : AppTheme.cardWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  border: isMe ? null : Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && message.author != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          message.author!.fullName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryGoldDark),
                        ),
                      ),
                    Text(
                      message.content ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final resolvedUrl = ImageUtils.optimizedAvatar(message.author?.avatarUrl);
    final initial = message.author?.fullName.isNotEmpty == true
        ? message.author!.fullName[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 14,
      backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
      backgroundImage: resolvedUrl.isNotEmpty ? CachedNetworkImageProvider(resolvedUrl) : null,
      child: resolvedUrl.isEmpty
          ? Text(initial, style: const TextStyle(fontSize: 10, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.bold))
          : null,
    );
  }

  Widget _buildDeletedBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.bgCreamDarker,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Tin nhắn đã bị xóa',
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
