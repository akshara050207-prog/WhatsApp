import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/call_model.dart';
import 'call_provider.dart';

class ActiveCallScreen extends ConsumerStatefulWidget {
  final CallModel call;
  final bool isCaller;

  const ActiveCallScreen({
    super.key,
    required this.call,
    required this.isCaller,
  });

  @override
  ConsumerState<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends ConsumerState<ActiveCallScreen> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isVideoOn = true;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _endCall() async {
    _timer?.cancel();
    await ref.read(callControllerProvider).endCall(widget.call.callId, duration: _seconds);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final peerName = widget.isCaller ? widget.call.receiverName : widget.call.callerName;
    final isVideo = widget.call.callType == 'video';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              peerName,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_seconds),
              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (!isVideo || !_isVideoOn) ...[
              CircleAvatar(
                radius: 70,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ] else ...[
              Container(
                width: 260,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam, size: 60, color: Colors.white54),
                      SizedBox(height: 10),
                      Text('NexTalk Encrypted Video', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Mute toggle
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _isMuted ? Colors.red : Colors.white24,
                    child: IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                    ),
                  ),

                  // Speaker toggle
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _isSpeaker ? AppColors.primary : Colors.white24,
                    child: IconButton(
                      icon: Icon(_isSpeaker ? Icons.volume_up : Icons.volume_down, color: Colors.white),
                      onPressed: () => setState(() => _isSpeaker = !_isSpeaker),
                    ),
                  ),

                  // Video toggle if video call
                  if (isVideo) ...[
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _isVideoOn ? AppColors.primary : Colors.white24,
                      child: IconButton(
                        icon: Icon(_isVideoOn ? Icons.videocam : Icons.videocam_off, color: Colors.white),
                        onPressed: () => setState(() => _isVideoOn = !_isVideoOn),
                      ),
                    ),
                  ],

                  // End Call
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
                      onPressed: _endCall,
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
