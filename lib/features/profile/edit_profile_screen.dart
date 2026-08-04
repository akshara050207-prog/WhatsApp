import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../auth/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _aboutController;
  bool _isLoading = false;
  String _usernameStatus = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _usernameController = TextEditingController(text: widget.user.username);
    _aboutController = TextEditingController(text: widget.user.about);
  }

  void _validateAndSave() async {
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String about = _aboutController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display Name cannot be empty')));
      return;
    }

    if (!username.startsWith('@')) username = '@$username';

    setState(() => _isLoading = true);

    bool isUnique = await ref.read(authControllerProvider).isUsernameUnique(username, widget.user.uid);
    if (!isUnique) {
      setState(() {
        _isLoading = false;
        _usernameStatus = 'Username already taken!';
      });
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
      'displayName': name,
      'username': username,
      'about': about,
    });

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username (Must be unique, e.g. @akshara)',
                errorText: _usernameStatus.isNotEmpty ? _usernameStatus : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _usernameStatus = ''),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aboutController,
              decoration: InputDecoration(
                labelText: 'About / Bio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateAndSave,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Profile Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
