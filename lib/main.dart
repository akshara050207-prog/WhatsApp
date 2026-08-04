import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: NexTalkApp(),
    ),
  );
}

class NexTalkApp extends ConsumerWidget {
  const NexTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexTalk',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}