import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String callerPhoto;
  final String receiverId;
  final String receiverName;
  final String receiverPhoto;
  final String callType; // 'voice' or 'video'
  final String status; // 'calling', 'accepted', 'rejected', 'ended'
  final DateTime timestamp;
  final int durationSeconds;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerPhoto = '',
    required this.receiverId,
    required this.receiverName,
    this.receiverPhoto = '',
    this.callType = 'voice',
    this.status = 'calling',
    required this.timestamp,
    this.durationSeconds = 0,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String docId) {
    return CallModel(
      callId: docId,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? 'Caller',
      callerPhoto: map['callerPhoto'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? 'Receiver',
      receiverPhoto: map['receiverPhoto'] ?? '',
      callType: map['callType'] ?? 'voice',
      status: map['status'] ?? 'calling',
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : DateTime.now(),
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'callType': callType,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'durationSeconds': durationSeconds,
    };
  }
}
