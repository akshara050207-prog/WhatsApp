import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String type; // 'direct' or 'group'
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final List<String> pinnedBy;
  final List<String> archivedBy;
  final Map<String, int> unreadCount;
  final Map<String, bool> isTyping;

  ChatModel({
    required this.chatId,
    this.type = 'direct',
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTime,
    this.pinnedBy = const [],
    this.archivedBy = const [],
    this.unreadCount = const {},
    this.isTyping = const {},
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatModel(
      chatId: docId,
      type: map['type'] ?? 'direct',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null ? (map['lastMessageTime'] as Timestamp).toDate() : null,
      pinnedBy: List<String>.from(map['pinnedBy'] ?? []),
      archivedBy: List<String>.from(map['archivedBy'] ?? []),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      isTyping: Map<String, bool>.from(map['isTyping'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'type': type,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : FieldValue.serverTimestamp(),
      'pinnedBy': pinnedBy,
      'archivedBy': archivedBy,
      'unreadCount': unreadCount,
      'isTyping': isTyping,
    };
  }
}
