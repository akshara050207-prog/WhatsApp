import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDocProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.displayName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              user.username,
              style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
            title: const Text('Phone Number', style: TextStyle(color: Colors.grey, fontSize: 12)),
            subtitle: Text(user.phone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('About / Bio', style: TextStyle(color: Colors.grey, fontSize: 12)),
            subtitle: Text(user.about, style: const TextStyle(fontSize: 16)),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
            title: const Text('Account Created', style: TextStyle(color: Colors.grey, fontSize: 12)),
            subtitle: Text(
              user.createdAt != null ? DateFormat('MMMM dd, yyyy').format(user.createdAt!) : 'Recently',
              style: const TextStyle(fontSize: 16),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.circle, color: AppColors.onlineIndicator, size: 16),
            title: const Text('Online Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
            subtitle: Text(user.isOnline ? 'Online' : 'Offline', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
