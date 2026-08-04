import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/status_model.dart';
import 'status_provider.dart';

class StatusViewScreen extends ConsumerStatefulWidget {
  final StatusModel status;

  const StatusViewScreen({super.key, required this.status});

  @override
  ConsumerState<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends ConsumerState<StatusViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statusControllerProvider).markStatusViewed(widget.status.statusId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.status.type == 'text'
          ? Color(widget.status.backgroundColor)
          : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text(
                widget.status.userName.isNotEmpty ? widget.status.userName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.status.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.status.type == 'text'
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          widget.status.caption,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.status.mediaUrl,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                        if (widget.status.caption.isNotEmpty) ...[
                          Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: Text(
                              widget.status.caption,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_red_eye, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.status.viewerUids.length} Views',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
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
