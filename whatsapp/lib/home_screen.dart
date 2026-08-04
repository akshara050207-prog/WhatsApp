import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Updates'),
              Tab(text: 'Communities'),
              Tab(text: 'Calls'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.qr_code, color: Colors.white),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.white),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {},
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'new_group', child: Text('New group')),
                PopupMenuItem(
                    value: 'settings', child: Text('Settings')),
                PopupMenuItem(
                    value: 'switch_account',
                    child: Text('Switch account')),
                PopupMenuItem(
                    value: 'payments', child: Text('Payments')),
                PopupMenuItem(
                    value: 'linked_devices',
                    child: Text('Linked devices')),
                PopupMenuItem(value: 'block', child: Text('Block')),
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Chats tab
            ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'M',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Mumma'),
                  subtitle: Text('jai jinendra'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'P',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Papa'),
                  subtitle: Text('jai jinendra'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'D',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Didi'),
                  subtitle: Text('Be Happy'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'J',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Jiju'),
                  subtitle: Text('Work Smart'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'M',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Manikarnika'),
                  subtitle: Text('Good night'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'S',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Sejal'),
                  subtitle: Text('Good Morning'),
                  trailing: Text('8:00 AM'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'D',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Devyani'),
                  subtitle: Text('Be Ready for college'),
                  trailing: Text('8:30 AM'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'A',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Aastha'),
                  subtitle:
                      Text('Complete your work tomorrow is submission'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'V',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Vanshika'),
                  subtitle: Text('I will not come tomorrow'),
                  trailing: Text('Yesterday'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'R',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Rishi'),
                  subtitle: Text('Thank You'),
                  trailing: Text('Just Now'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0x2C96094F),
                    child: Text(
                      'B',
                      style: TextStyle(color: Color(0xFFA32473)),
                    ),
                  ),
                  title: Text('Bhai'),
                  subtitle: Text('send me work'),
                  trailing: Text('1 min ago'),
                ),
              ],
            ),

            // Updates tab
            const Center(
              child: Text(
                'Status updates will appear here',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),

            // Communities tab
            const Center(
              child: Text(
                'Groups will appear here',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),

            // Calls tab
            const Center(
              child: Text(
                'Call logs will appear here',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF7E1449),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New chat button pressed')),
            );
          },
          child: const Icon(Icons.message),
        ),
      ),
    );
  }
}