import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../auth/auth_provider.dart';
import 'chat_detail_screen.dart';
import 'chat_provider.dart';

class SearchChatScreen extends ConsumerStatefulWidget {
  const SearchChatScreen({super.key});

  @override
  ConsumerState<SearchChatScreen> createState() => _SearchChatScreenState();
}

class _SearchChatScreenState extends ConsumerState<SearchChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currentUid = ref.watch(authControllerProvider).currentUid;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search people or chats...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() => _query = val.trim().toLowerCase());
          },
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Type to search users on NexTalk'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final results = snapshot.data!.docs
                    .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
                    .where((u) => u.uid != currentUid)
                    .where((u) =>
                        u.displayName.toLowerCase().contains(_query) ||
                        u.username.toLowerCase().contains(_query) ||
                        u.phone.contains(_query))
                    .toList();

                if (results.isEmpty) {
                  return const Center(child: Text('No users match your search'));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final user = results[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.username),
                      onTap: () {
                        final chatId = ref.read(chatControllerProvider).getOrCreateChatRoomId(user.uid);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              chatId: chatId,
                              receiverUid: user.uid,
                              receiverName: user.displayName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
