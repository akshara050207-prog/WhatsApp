import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/call_model.dart';

final incomingCallStreamProvider = StreamProvider<CallModel?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('calls')
      .where('receiverId', isEqualTo: uid)
      .where('status', isEqualTo: 'calling')
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return CallModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      });
});

final callHistoryStreamProvider = StreamProvider<List<CallModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('calls')
      .where('callerId', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => CallModel.fromMap(doc.data(), doc.id)).toList());
});

class CallController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Initiate Voice / Video Call
  Future<CallModel> makeCall({
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required String callerName,
    required String callerPhoto,
    required String callType, // 'voice' or 'video'
  }) async {
    final docRef = _firestore.collection('calls').doc();
    CallModel call = CallModel(
      callId: docRef.id,
      callerId: currentUid,
      callerName: callerName,
      callerPhoto: callerPhoto,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhoto: receiverPhoto,
      callType: callType,
      status: 'calling',
      timestamp: DateTime.now(),
    );

    await docRef.set(call.toMap());
    return call;
  }

  /// Accept Call
  Future<void> acceptCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({'status': 'accepted'});
  }

  /// Reject Call
  Future<void> rejectCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({'status': 'rejected'});
  }

  /// End Call
  Future<void> endCall(String callId, {int duration = 0}) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
      'durationSeconds': duration,
    });
  }
}

final callControllerProvider = Provider<CallController>((ref) => CallController());
