import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/call_model.dart';
import 'active_call_screen.dart';
import 'call_provider.dart';

class IncomingCallScreen extends ConsumerWidget {
  final CallModel call;

  const IncomingCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              'Incoming ${call.callType == 'video' ? 'Video' : 'Voice'} Call',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              call.callerName,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.3),
              child: const Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Reject Button
                  GestureDetector(
                    onTap: () async {
                      await ref.read(callControllerProvider).rejectCall(call.callId);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.call_end, color: Colors.white, size: 30),
                        ),
                        SizedBox(height: 8),
                        Text('Decline', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  // Accept Button
                  GestureDetector(
                    onTap: () async {
                      await ref.read(callControllerProvider).acceptCall(call.callId);
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActiveCallScreen(call: call, isCaller: false),
                          ),
                        );
                      }
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.call, color: Colors.white, size: 30),
                        ),
                        SizedBox(height: 8),
                        Text('Accept', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
