import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/crypto/e2e_encryption.dart';
import '../../core/services/storage_service.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

final chatStreamProvider = StreamProvider<List<ChatModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromMap(doc.data(), doc.id)).toList());
});

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Create or fetch chatRoomId between current user and target user
  String getOrCreateChatRoomId(String otherUid) {
    List<String> ids = [currentUid, otherUid];
    ids.sort();
    return ids.join('_');
  }

  /// Ensure Chat document exists in Firestore
  Future<void> ensureChatExists(String chatId, List<String> participants) async {
    DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    DocumentSnapshot doc = await chatRef.get();
    if (!doc.exists) {
      await chatRef.set({
        'chatId': chatId,
        'type': 'direct',
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'pinnedBy': [],
        'archivedBy': [],
        'unreadCount': {},
        'isTyping': {},
      });
    }
  }

  /// Send Encrypted Message
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    String mediaUrl = '',
    String mediaType = 'text',
    String mediaName = '',
    String replyToId = '',
    String replyToText = '',
  }) async {
    if (text.trim().isEmpty && mediaUrl.isEmpty) return;

    await ensureChatExists(chatId, [currentUid, receiverId]);

    // Encrypt message content via E2EEncryption
    final encryptedData = await E2EEncryption.encryptMessage(text.trim(), chatId, currentUid);

    DocumentReference msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    MessageModel message = MessageModel(
      messageId: msgRef.id,
      senderId: currentUid,
      receiverId: receiverId,
      encryptedContent: encryptedData['cipher']!,
      iv: encryptedData['iv']!,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      mediaName: mediaName,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      replyToText: replyToText,
      status: 'sent',
    );

    await msgRef.set(message.toMap());

    // Update last message in chat document
    String displaySummary = mediaType == 'text' ? (text.length > 30 ? '${text.substring(0, 30)}...' : text) : '📷 $mediaType';
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': displaySummary,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Send Media Message (Image, Video, Document, Voice, Audio)
  Future<void> sendMediaMessage({
    required String chatId,
    required String receiverId,
    required File file,
    required String mediaType,
    required String fileName,
  }) async {
    String downloadUrl = await StorageService.uploadFile(
      file: file,
      folder: 'chat_media/$chatId',
      fileName: fileName,
    );

    await sendMessage(
      chatId: chatId,
      receiverId: receiverId,
      text: mediaType == 'image' ? 'Photo' : (mediaType == 'video' ? 'Video' : fileName),
      mediaUrl: downloadUrl,
      mediaType: mediaType,
      mediaName: fileName,
    );
  }

  /// Update Typing Indicator
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    if (currentUid.isEmpty) return;
    await _firestore.collection('chats').doc(chatId).set({
      'isTyping': {currentUid: isTyping}
    }, SetOptions(merge: true));
  }

  /// Add/Remove Message Reaction
  Future<void> toggleReaction(String chatId, String messageId, String emoji) async {
    DocumentReference msgRef = _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId);
    DocumentSnapshot doc = await msgRef.get();
    if (!doc.exists) return;

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, String> reactions = Map<String, String>.from(data['reactions'] ?? {});

    if (reactions[currentUid] == emoji) {
      reactions.remove(currentUid);
    } else {
      reactions[currentUid] = emoji;
    }

    await msgRef.update({'reactions': reactions});
  }

  /// Edit Sent Message
  Future<void> editMessage(String chatId, String messageId, String newText) async {
    final encryptedData = await E2EEncryption.encryptMessage(newText, chatId, currentUid);
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'encryptedContent': encryptedData['cipher'],
      'iv': encryptedData['iv'],
      'isEdited': true,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete for Me
  Future<void> deleteForMe(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'deletedFor': FieldValue.arrayUnion([currentUid]),
    });
  }

  /// Delete for Everyone
  Future<void> deleteForEveryone(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'encryptedContent': '',
      'iv': 'plain',
      'mediaUrl': '',
      'mediaType': 'text',
      'status': 'deleted',
    });
  }

  /// Toggle Pin Chat
  Future<void> togglePinChat(String chatId, bool isPinned) async {
    DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    if (isPinned) {
      await chatRef.update({'pinnedBy': FieldValue.arrayRemove([currentUid])});
    } else {
      await chatRef.update({'pinnedBy': FieldValue.arrayUnion([currentUid])});
    }
  }

  /// Toggle Archive Chat
  Future<void> toggleArchiveChat(String chatId, bool isArchived) async {
    DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    if (isArchived) {
      await chatRef.update({'archivedBy': FieldValue.arrayRemove([currentUid])});
    } else {
      await chatRef.update({'archivedBy': FieldValue.arrayUnion([currentUid])});
    }
  }

  /// Mark message read receipt
  Future<void> markMessageRead(String chatId, String messageId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
      'status': 'read',
      'readBy': FieldValue.arrayUnion([currentUid]),
    }).catchError((_) {});
  }
}

final chatControllerProvider = Provider<ChatController>((ref) => ChatController());
