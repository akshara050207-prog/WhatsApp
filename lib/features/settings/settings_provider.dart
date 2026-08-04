import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme');
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }
}

class SettingsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Block User
  Future<void> blockUser(String targetUid) async {
    if (currentUid.isEmpty) return;
    await _firestore.collection('users').doc(currentUid).update({
      'blockedUsers': FieldValue.arrayUnion([targetUid]),
    });
  }

  /// Unblock User
  Future<void> unblockUser(String targetUid) async {
    if (currentUid.isEmpty) return;
    await _firestore.collection('users').doc(currentUid).update({
      'blockedUsers': FieldValue.arrayRemove([targetUid]),
    });
  }

  /// Report User
  Future<void> reportUser(String targetUid, String reason) async {
    await _firestore.collection('reports').add({
      'reporterId': currentUid,
      'targetId': targetUid,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Delete User Account
  Future<void> deleteAccount() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      await _firestore.collection('users').doc(uid).delete();
      await currentUser.delete();
    }
  }
}

final settingsControllerProvider = Provider<SettingsController>((ref) => SettingsController());
