import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phone;
  final String displayName;
  final String username;
  final String photoUrl;
  final String about;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? createdAt;
  final List<String> blockedUsers;
  final String pushToken;

  UserModel({
    required this.uid,
    required this.phone,
    required this.displayName,
    required this.username,
    required this.photoUrl,
    required this.about,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
    this.blockedUsers = const [],
    this.pushToken = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      phone: map['phone'] ?? '',
      displayName: map['displayName'] ?? map['name'] ?? 'NexTalk User',
      username: map['username'] ?? '@user_${docId.substring(0, 5)}',
      photoUrl: map['photoUrl'] ?? '',
      about: map['about'] ?? map['status'] ?? 'Hey there! I am using NexTalk.',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? (map['lastSeen'] as Timestamp).toDate() : null,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      pushToken: map['pushToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'about': about,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : FieldValue.serverTimestamp(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'blockedUsers': blockedUsers,
      'pushToken': pushToken,
    };
  }
}
