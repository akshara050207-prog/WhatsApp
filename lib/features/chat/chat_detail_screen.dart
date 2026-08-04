import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/crypto/e2e_encryption.dart';
import '../../models/message_model.dart';
import '../call/call_provider.dart';
import '../call/active_call_screen.dart';
import 'chat_provider.dart';
import 'widgets/chat_bubble.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String receiverUid;
  final String receiverName;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.receiverUid,
    required this.receiverName,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String _replyingToText = '';
  String _replyingToId = '';

  void _sendMessage() {
    String text = _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatControllerProvider).sendMessage(
      chatId: widget.chatId,
      receiverId: widget.receiverUid,
      text: text,
      replyToId: _replyingToId,
      replyToText: _replyingToText,
    );

    _messageController.clear();
    setState(() {
      _replyingToId = '';
      _replyingToText = '';
    });
  }

  void _pickAndSendImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      ref.read(chatControllerProvider).sendMediaMessage(
        chatId: widget.chatId,
        receiverId: widget.receiverUid,
        file: File(image.path),
        mediaType: 'image',
        fileName: image.name,
      );
    }
  }

  void _pickAndSendDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      ref.read(chatControllerProvider).sendMediaMessage(
        chatId: widget.chatId,
        receiverId: widget.receiverUid,
        file: File(result.files.single.path!),
        mediaType: 'document',
        fileName: result.files.single.name,
      );
    }
  }

  void _startVoiceOrVideoCall(String callType) async {
    final call = await ref.read(callControllerProvider).makeCall(
      receiverId: widget.receiverUid,
      receiverName: widget.receiverName,
      callerName: 'Me',
      callerPhoto: '',
      receiverPhoto: '',
      callType: callType,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveCallScreen(call: call, isCaller: true),
        ),
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAttachmentItem(Icons.camera_alt, 'Camera', () {
              Navigator.pop(context);
              _pickAndSendImage(ImageSource.camera);
            }),
            _buildAttachmentItem(Icons.photo_library, 'Gallery', () {
              Navigator.pop(context);
              _pickAndSendImage(ImageSource.gallery);
            }),
            _buildAttachmentItem(Icons.insert_drive_file, 'Document', () {
              Navigator.pop(context);
              _pickAndSendDocument();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showOptionsModal(MessageModel msg, String decrypted) {
    final currentUid = ref.read(chatControllerProvider).currentUid;
    final isMe = msg.senderId == currentUid;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji reaction row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['❤️', '👍', '😂', '😮', '😢', '🔥'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(chatControllerProvider).toggleReaction(widget.chatId, msg.messageId, emoji);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _replyingToId = msg.messageId;
                _replyingToText = decrypted;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete for Me'),
            onTap: () {
              Navigator.pop(context);
              ref.read(chatControllerProvider).deleteForMe(widget.chatId, msg.messageId);
            },
          ),
          if (isMe) ...[
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete for Everyone', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatControllerProvider).deleteForEveryone(widget.chatId, msg.messageId);
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = ref.read(chatControllerProvider).currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('🔒 End-to-End Encrypted', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startVoiceOrVideoCall('voice'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startVoiceOrVideoCall('video'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Send a message to start E2EE chat!'),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final message = MessageModel.fromMap(data, docs[index].id);

                    if (message.deletedFor.contains(currentUid)) return const SizedBox();

                    bool isMe = message.senderId == currentUid;

                    return FutureBuilder<String>(
                      future: E2EEncryption.decryptMessage(
                        message.encryptedContent,
                        message.iv,
                        widget.chatId,
                        currentUid,
                      ),
                      builder: (context, decryptSnap) {
                        final decryptedText = decryptSnap.data ?? 'Decrypting...';

                        return ChatBubble(
                          message: message,
                          decryptedText: decryptedText,
                          isMe: isMe,
                          onLongPress: () => _showOptionsModal(message, decryptedText),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Reply Bar Preview
          if (_replyingToText.isNotEmpty) ...[
            Container(
              color: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to: $_replyingToText',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _replyingToText = ''),
                  ),
                ],
              ),
            ),
          ],

          // Input Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.primary),
                    onPressed: _showAttachmentOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (val) {
                        ref.read(chatControllerProvider).setTypingStatus(widget.chatId, val.isNotEmpty);
                      },
                      decoration: InputDecoration(
                        hintText: 'Type an encrypted message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
