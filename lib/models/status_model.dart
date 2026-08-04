import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String statusId;
  final String uid;
  final String userName;
  final String userPhoto;
  final String mediaUrl;
  final String caption;
  final String type; // 'image', 'video', 'text'
  final int backgroundColor;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewerUids;

  StatusModel({
    required this.statusId,
    required this.uid,
    required this.userName,
    this.userPhoto = '',
    this.mediaUrl = '',
    this.caption = '',
    this.type = 'text',
    this.backgroundColor = 0xFF6366F1,
    required this.createdAt,
    required this.expiresAt,
    this.viewerUids = const [],
  });

  factory StatusModel.fromMap(Map<String, dynamic> map, String docId) {
    return StatusModel(
      statusId: docId,
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? 'User',
      userPhoto: map['userPhoto'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      caption: map['caption'] ?? '',
      type: map['type'] ?? 'text',
      backgroundColor: map['backgroundColor'] ?? 0xFF6366F1,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      expiresAt: map['expiresAt'] != null ? (map['expiresAt'] as Timestamp).toDate() : DateTime.now().add(const Duration(hours: 24)),
      viewerUids: List<String>.from(map['viewerUids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statusId': statusId,
      'uid': uid,
      'userName': userName,
      'userPhoto': userPhoto,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'type': type,
      'backgroundColor': backgroundColor,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewerUids': viewerUids,
    };
  }
}
