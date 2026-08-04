import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../auth/auth_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  bool _isLoading = false;

  void _createGroup() async {
    String name = _groupNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter group name')));
      return;
    }
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least 1 member')));
      return;
    }

    setState(() => _isLoading = true);
    final currentUid = ref.read(authControllerProvider).currentUid;
    if (currentUid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final groupRef = FirebaseFirestore.instance.collection('groups').doc();

    List<String> members = [currentUid, ..._selectedUserIds];

    await groupRef.set({
      'groupId': groupRef.id,
      'name': name,
      'description': 'NexTalk Group',
      'avatarUrl': '',
      'adminIds': [currentUid],
      'memberIds': members,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chats').doc(groupRef.id).set({
      'chatId': groupRef.id,
      'type': 'group',
      'participants': members,
      'lastMessage': 'Group created',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'pinnedBy': [],
      'archivedBy': [],
      'unreadCount': {},
      'isTyping': {},
    });

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = ref.watch(authControllerProvider).currentUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('SELECT MEMBERS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!.docs
                    .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
                    .where((u) => u.uid != currentUid)
                    .toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    bool isSelected = _selectedUserIds.contains(user.uid);

                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.about),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedUserIds.add(user.uid);
                          } else {
                            _selectedUserIds.remove(user.uid);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Create Group (${_selectedUserIds.length})'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
