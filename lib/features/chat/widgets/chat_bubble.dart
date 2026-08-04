import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final String decryptedText;
  final bool isMe;
  final Function(String emoji)? onReactionSelected;
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.message,
    required this.decryptedText,
    required this.isMe,
    this.onReactionSelected,
    this.onLongPress,
  });

  Widget _buildStatusTicks() {
    if (!isMe) return const SizedBox();

    if (message.status == 'read') {
      return const Icon(Icons.done_all, size: 16, color: AppColors.readTick);
    } else if (message.status == 'delivered') {
      return const Icon(Icons.done_all, size: 16, color: AppColors.unreadTick);
    } else {
      return const Icon(Icons.check, size: 16, color: AppColors.unreadTick);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? (isDark ? AppColors.darkBubbleSender : AppColors.lightBubbleSender)
        : (isDark ? AppColors.darkBubbleReceiver : AppColors.lightBubbleReceiver);

    final textColor = isMe
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply preview
              if (message.replyToText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(left: BorderSide(color: isMe ? Colors.white : AppColors.primary, width: 3)),
                  ),
                  child: Text(
                    message.replyToText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8)),
                  ),
                ),
              ],

              // Media content
              if (message.mediaUrl.isNotEmpty) ...[
                if (message.mediaType == 'image') ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: message.mediaUrl,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 6),
                ] else if (message.mediaType == 'document' || message.mediaType == 'audio' || message.mediaType == 'voice') ...[
                  Row(
                    children: [
                      Icon(
                        message.mediaType == 'document'
                            ? Icons.insert_drive_file
                            : (message.mediaType == 'voice' ? Icons.mic : Icons.audiotrack),
                        color: textColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.mediaName.isNotEmpty ? message.mediaName : message.mediaType.toUpperCase(),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ],

              // Message text
              Text(
                decryptedText,
                style: TextStyle(color: textColor, fontSize: 15),
              ),

              const SizedBox(height: 4),

              // Timestamp & status ticks
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (message.isEdited) ...[
                    Text(
                      'edited • ',
                      style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
                    ),
                  ],
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
                  ),
                  const SizedBox(width: 4),
                  _buildStatusTicks(),
                ],
              ),

              // Reactions
              if (message.reactions.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: message.reactions.values.map((emoji) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
