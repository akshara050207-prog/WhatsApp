class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;

  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
  });
}

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );
}
