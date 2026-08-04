import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String encryptedContent;
  final String iv;
  final String mediaUrl;
  final String mediaType; // 'text', 'image', 'video', 'document', 'audio', 'voice'
  final String mediaName;
  final DateTime timestamp;
  final String replyToId;
  final String replyToText;
  final bool isEdited;
  final DateTime? editedAt;
  final List<String> readBy;
  final String status; // 'sent', 'delivered', 'read'
  final Map<String, String> reactions; // userId -> emoji
  final List<String> deletedFor; // list of uids
  final bool isStarred;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.encryptedContent,
    required this.iv,
    this.mediaUrl = '',
    this.mediaType = 'text',
    this.mediaName = '',
    required this.timestamp,
    this.replyToId = '',
    this.replyToText = '',
    this.isEdited = false,
    this.editedAt,
    this.readBy = const [],
    this.status = 'sent',
    this.reactions = const {},
    this.deletedFor = const [],
    this.isStarred = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      messageId: docId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      encryptedContent: map['encryptedContent'] ?? map['message'] ?? '',
      iv: map['iv'] ?? 'plain',
      mediaUrl: map['mediaUrl'] ?? '',
      mediaType: map['mediaType'] ?? 'text',
      mediaName: map['mediaName'] ?? '',
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : DateTime.now(),
      replyToId: map['replyToId'] ?? '',
      replyToText: map['replyToText'] ?? '',
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null ? (map['editedAt'] as Timestamp).toDate() : null,
      readBy: List<String>.from(map['readBy'] ?? []),
      status: map['status'] ?? 'sent',
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
      deletedFor: List<String>.from(map['deletedFor'] ?? []),
      isStarred: map['isStarred'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'encryptedContent': encryptedContent,
      'iv': iv,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'mediaName': mediaName,
      'timestamp': Timestamp.fromDate(timestamp),
      'replyToId': replyToId,
      'replyToText': replyToText,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'readBy': readBy,
      'status': status,
      'reactions': reactions,
      'deletedFor': deletedFor,
      'isStarred': isStarred,
    };
  }
}
