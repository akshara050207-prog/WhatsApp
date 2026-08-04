import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String description;
  final String avatarUrl;
  final List<String> adminIds;
  final List<String> memberIds;
  final DateTime createdAt;

  GroupModel({
    required this.groupId,
    required this.name,
    this.description = '',
    this.avatarUrl = '',
    required this.adminIds,
    required this.memberIds,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String docId) {
    return GroupModel(
      groupId: docId,
      name: map['name'] ?? 'NexTalk Group',
      description: map['description'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
