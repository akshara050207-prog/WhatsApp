import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import '../chat/chat_provider.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/search_chat_screen.dart';
import '../chat/create_group_screen.dart';
import '../contacts/contacts_screen.dart';
import '../status/status_screen.dart';
import '../call/call_history_screen.dart';
import '../call/call_provider.dart';
import '../call/incoming_call_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Update online status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider).setUserPresence(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for incoming voice/video calls
    final incomingCall = ref.watch(incomingCallStreamProvider).value;
    if (incomingCall != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(call: incomingCall),
          ),
        );
      });
    }

    final List<Widget> pages = [
      const ChatListTab(),
      const StatusScreen(),
      const CallHistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'NexTalk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchChatScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'group') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
                );
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else if (value == 'settings') {
                setState(() => _selectedIndex = 3);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'group', child: Text('New Group')),
              const PopupMenuItem(value: 'profile', child: Text('My Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactsScreen()),
                );
              },
              child: const Icon(Icons.message, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat, color: AppColors.primary),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.motion_photos_on_outlined),
            selectedIcon: Icon(Icons.motion_photos_on, color: AppColors.primary),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call, color: AppColors.primary),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ChatListTab extends ConsumerWidget {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatStreamProvider);
    final currentUid = ref.watch(authControllerProvider).currentUid;

    return chatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_chat_unread_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No conversations yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the button below to start a new E2EE chat',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final otherUid = chat.participants.firstWhere(
              (id) => id != currentUid,
              orElse: () => currentUid ?? '',
            );

            bool isPinned = chat.pinnedBy.contains(currentUid);
            bool isArchived = chat.archivedBy.contains(currentUid);
            if (isArchived) return const SizedBox();

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'User ${otherUid.length >= 5 ? otherUid.substring(0, 5) : otherUid}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (chat.lastMessageTime != null)
                    Text(
                      DateFormat('hh:mm a').format(chat.lastMessageTime!),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Encrypted Message',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  if (isPinned) const Icon(Icons.push_pin, size: 16, color: AppColors.primary),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      chatId: chat.chatId,
                      receiverUid: otherUid,
                      receiverName: 'User ${otherUid.length >= 5 ? otherUid.substring(0, 5) : otherUid}',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
