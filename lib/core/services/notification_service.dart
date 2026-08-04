import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        await updatePushToken(token);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        updatePushToken(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Foreground notification received: ${message.notification?.title}");
      });
    }
  }

  static Future<void> updatePushToken(String token) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'pushToken': token}).catchError((_) {});
    }
  }
}
