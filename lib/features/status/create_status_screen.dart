import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import 'status_provider.dart';

class CreateStatusScreen extends ConsumerStatefulWidget {
  final File? imageFile;

  const CreateStatusScreen({super.key, this.imageFile});

  @override
  ConsumerState<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends ConsumerState<CreateStatusScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  void _postStatus() async {
    final user = ref.read(currentUserDocProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      if (widget.imageFile != null) {
        await ref.read(statusControllerProvider).postMediaStatus(
          file: widget.imageFile!,
          type: 'image',
          caption: _captionController.text.trim(),
          userName: user.displayName,
          userPhoto: user.photoUrl,
        );
      } else {
        await ref.read(statusControllerProvider).postTextStatus(
          caption: _captionController.text.trim(),
          userName: user.displayName,
          userPhoto: user.photoUrl,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.imageFile == null ? AppColors.primary : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('New Status'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.imageFile != null
                  ? Image.file(widget.imageFile!, fit: BoxFit.contain)
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: TextField(
                          controller: _captionController,
                          maxLines: 5,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'Type a status update...',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
            ),
            if (widget.imageFile != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _captionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: AppColors.secondary,
                  onPressed: _isLoading ? null : _postStatus,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
