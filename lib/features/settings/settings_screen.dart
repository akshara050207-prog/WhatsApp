import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('Are you sure you want to delete your NexTalk account? This action is permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsControllerProvider).deleteAccount();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final user = ref.watch(currentUserDocProvider).value;

    return Scaffold(
      body: ListView(
        children: [
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(user.username, style: const TextStyle(color: AppColors.primary)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
          ],

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
            title: const Text('Dark Theme'),
            subtitle: const Text('Toggle between Light & Dark Material 3 Mode'),
            value: isDark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggleTheme(val);
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.primary),
            title: const Text('Privacy & Security'),
            subtitle: const Text('End-to-End Encryption & Security Settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All messages are protected by Signal-style E2E Encryption.')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.block_outlined, color: AppColors.primary),
            title: const Text('Blocked Users'),
            subtitle: const Text('Manage your blocked contacts list'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No blocked users.')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
            title: const Text('Report an Issue'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted to NexTalk Support.')),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmDeleteAccount(context, ref),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
