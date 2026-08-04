import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authProvider).authStateChanges();
});

final currentUserDocProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
});

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUid => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  /// Send Phone Verification OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "Phone verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verify OTP and log in / create user doc
  Future<bool> verifyOTP({
    required String verificationId,
    required String smsCode,
    required Function(String error) onError,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _createOrUpdateUserDoc(userCredential.user!);
        return true;
      }
      return false;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  Future<void> _signInWithCredential(AuthCredential credential) async {
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    if (userCredential.user != null) {
      await _createOrUpdateUserDoc(userCredential.user!);
    }
  }

  /// Auto create or merge Firestore user document
  Future<void> _createOrUpdateUserDoc(User user) async {
    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
    DocumentSnapshot snapshot = await userDoc.get();

    if (!snapshot.exists) {
      String defaultUsername = '@user_${user.uid.substring(0, 5).toLowerCase()}';
      await userDoc.set({
        'uid': user.uid,
        'phone': user.phoneNumber ?? '',
        'displayName': 'User ${user.phoneNumber != null && user.phoneNumber!.length >= 4 ? user.phoneNumber!.substring(user.phoneNumber!.length - 4) : ""}',
        'username': defaultUsername,
        'photoUrl': '',
        'about': 'Hey there! I am using NexTalk.',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'blockedUsers': [],
        'pushToken': '',
      });
    } else {
      await userDoc.update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Check username uniqueness
  Future<bool> isUsernameUnique(String username, String currentUid) async {
    if (!username.startsWith('@')) username = '@$username';
    QuerySnapshot query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (query.docs.isEmpty) return true;
    return query.docs.first.id == currentUid;
  }

  /// Update Online status
  Future<void> setUserPresence(bool isOnline) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      }).catchError((_) {});
    }
  }

  Future<void> signOut() async {
    await setUserPresence(false);
    await _auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController());
