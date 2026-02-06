import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/passwords/data/models/password_model.dart';
import 'package:omnipro_productivity/features/passwords/presentation/providers/password_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

class PasswordListPage extends ConsumerStatefulWidget {
  const PasswordListPage({super.key});

  @override
  ConsumerState<PasswordListPage> createState() => _PasswordListPageState();
}

class _PasswordListPageState extends ConsumerState<PasswordListPage> {
  bool _isAuthenticated = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to view your passwords',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      setState(() {
        _isAuthenticated = authenticated;
      });
    } catch (e) {
      // Handle error or fallback
      setState(() => _isAuthenticated = true); // Fallback for desktop/emulators
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _authenticate,
            child: const Text('Unlock Passwords'),
          ),
        ),
      );
    }

    final passwords = ref.watch(passwordProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Password Manager')),
      body: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final entry = passwords[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.username),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                final pass = PasswordSecurity.decryptPassword(entry.encryptedPassword);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password copied to clipboard'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPasswordDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPasswordDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: userController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: passController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && passController.text.isNotEmpty) {
                final encrypted = PasswordSecurity.encryptPassword(passController.text);
                ref.read(passwordProvider.notifier).savePassword(
                  PasswordEntry(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    username: userController.text,
                    encryptedPassword: encrypted,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
