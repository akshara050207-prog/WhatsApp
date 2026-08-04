import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/contacts_service.dart';
import '../chat/chat_detail_screen.dart';
import '../chat/chat_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  bool _isLoading = true;
  List<RegisteredContactMatch> _registeredUsers = [];
  List<Contact> _unregisteredContacts = [];
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final result = await ContactsService.fetchAndMatchContacts();
    setState(() {
      _isLoading = false;
      _permissionDenied = result['permissionDenied'] ?? false;
      _registeredUsers = List<RegisteredContactMatch>.from(result['registered'] ?? []);
      _unregisteredContacts = List<Contact>.from(result['unregistered'] ?? []);
    });
  }

  void _sendInvite(String phone) async {
    final Uri smsUri = Uri.parse('sms:$phone?body=Hey! Join me on NexTalk - the secure, E2E encrypted messaging app.');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _permissionDenied
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Contacts Permission Required',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please grant contacts permission to discover your friends on NexTalk.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadContacts,
                          child: const Text('Grant Permission'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  children: [
                    if (_registeredUsers.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'REGISTERED ON NEXTALK',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      ..._registeredUsers.map((match) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              match.contactName.isNotEmpty ? match.contactName[0].toUpperCase() : 'U',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(match.contactName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(match.userModel.about, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('NexTalk', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          onTap: () {
                            final chatId = ref.read(chatControllerProvider).getOrCreateChatRoomId(match.userModel.uid);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  chatId: chatId,
                                  receiverUid: match.userModel.uid,
                                  receiverName: match.contactName,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                    if (_unregisteredContacts.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'INVITE TO NEXTALK',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      ..._unregisteredContacts.map((contact) {
                        String phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                        final displayName = contact.displayName;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              (displayName != null && displayName.isNotEmpty) ? displayName[0].toUpperCase() : 'C',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          title: Text(displayName ?? 'Unknown'),
                          subtitle: Text(phone),
                          trailing: TextButton(
                            onPressed: () => _sendInvite(phone),
                            child: const Text('Invite', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
    );
  }
}
