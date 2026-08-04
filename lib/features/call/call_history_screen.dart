import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../contacts/contacts_screen.dart';
import 'call_provider.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(callHistoryStreamProvider);

    return Scaffold(
      body: callsAsync.when(
        data: (calls) {
          if (calls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call_end_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No recent calls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('To make a call, tap the contact button below', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    call.callType == 'video' ? Icons.videocam : Icons.call,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(call.receiverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    Icon(
                      call.status == 'ended' ? Icons.call_made : Icons.call_missed,
                      size: 16,
                      color: call.status == 'ended' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM dd, hh:mm a').format(call.timestamp)),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(call.callType == 'video' ? Icons.videocam : Icons.call, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactsScreen()),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactsScreen()),
          );
        },
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }
}
