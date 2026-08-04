import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../../models/status_model.dart';

final statusStreamProvider = StreamProvider<List<StatusModel>>((ref) {
  final now = DateTime.now();
  return FirebaseFirestore.instance
      .collection('statuses')
      .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => StatusModel.fromMap(doc.data(), doc.id)).toList());
});

class StatusController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Create text status
  Future<void> postTextStatus({
    required String caption,
    required String userName,
    required String userPhoto,
    int backgroundColor = 0xFF6366F1,
  }) async {
    final now = DateTime.now();
    final docRef = _firestore.collection('statuses').doc();

    StatusModel status = StatusModel(
      statusId: docRef.id,
      uid: currentUid,
      userName: userName,
      userPhoto: userPhoto,
      caption: caption,
      type: 'text',
      backgroundColor: backgroundColor,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );

    await docRef.set(status.toMap());
  }

  /// Create media status (image / video)
  Future<void> postMediaStatus({
    required File file,
    required String type,
    required String caption,
    required String userName,
    required String userPhoto,
  }) async {
    String downloadUrl = await StorageService.uploadFile(
      file: file,
      folder: 'statuses',
      fileName: '${type}_${DateTime.now().millisecondsSinceEpoch}',
    );

    final now = DateTime.now();
    final docRef = _firestore.collection('statuses').doc();

    StatusModel status = StatusModel(
      statusId: docRef.id,
      uid: currentUid,
      userName: userName,
      userPhoto: userPhoto,
      mediaUrl: downloadUrl,
      caption: caption,
      type: type,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );

    await docRef.set(status.toMap());
  }

  /// Record story view
  Future<void> markStatusViewed(String statusId) async {
    if (currentUid.isEmpty) return;
    await _firestore.collection('statuses').doc(statusId).update({
      'viewerUids': FieldValue.arrayUnion([currentUid]),
    }).catchError((_) {});
  }
}

final statusControllerProvider = Provider<StatusController>((ref) => StatusController());
