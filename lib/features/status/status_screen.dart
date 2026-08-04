import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import 'create_status_screen.dart';
import 'status_provider.dart';
import 'status_view_screen.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  void _pickStatusImage(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateStatusScreen(imageFile: File(image.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(statusStreamProvider);

    return Scaffold(
      body: ListView(
        children: [
          // My Status Header
          ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            title: const Text('My Status', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Tap to add 24-hour status update'),
            onTap: () => _pickStatusImage(context, ref),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('RECENT UPDATES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),

          statusesAsync.when(
            data: (statuses) {
              if (statuses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No recent status updates from your contacts')),
                );
              }

              return Column(
                children: statuses.map((status) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          status.userName.isNotEmpty ? status.userName[0].toUpperCase() : 'S',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                    title: Text(status.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Views: ${status.viewerUids.length} • 24h Expiring'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusViewScreen(status: status),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'textStatus',
            backgroundColor: AppColors.secondary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateStatusScreen(imageFile: null),
                ),
              );
            },
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'mediaStatus',
            backgroundColor: AppColors.primary,
            onPressed: () => _pickStatusImage(context, ref),
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
