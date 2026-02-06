import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/core/utils/data_exporter.dart';
import 'package:omnipro_productivity/features/todo/presentation/providers/todo_provider.dart';
import 'package:omnipro_productivity/features/notes/presentation/providers/notes_provider.dart';
import 'package:omnipro_productivity/features/expenses/presentation/providers/expense_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataManagementPage extends ConsumerWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPrivacyInfo(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Export'),
          _buildExportTile(context, ref, 'All Todos', Icons.check_circle, 'Export your task list'),
          _buildExportTile(context, ref, 'All Notes', Icons.note, 'Export your notes'),
          _buildExportTile(context, ref, 'All Expenses', Icons.attach_money, 'Export financial records'),
          
          const Divider(height: 32),
          
          _buildSectionHeader('Import'),
          _buildImportTile(context, 'Restore from Backup', Icons.restore, 'Import previously exported data'),
          
          const Divider(height: 32),
          
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _confirmLogout(context, ref),
          ),
          
          const Divider(height: 32),
          
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('100% Offline. Your data never leaves your device.'),
          ),
          const ListTile(
            leading: Icon(Icons.data_object),
            title: Text('Storage Used'),
            subtitle: Text('All data stored locally'),
          ),
          const ListTile(
            leading: Icon(Icons.app_settings_alt),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple[700],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildExportTile(BuildContext context, WidgetRef ref, String title, IconData icon, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text('Export $title'),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _exportData(context, ref, title.toLowerCase()),
      ),
    );
  }

  Widget _buildImportTile(BuildContext context, String title, IconData icon, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showImportDialog(context),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref, String type) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      Map<String, dynamic> exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'data': {},
      };

      if (type.contains('todo')) {
        final todos = ref.read(todoProvider);
        final todosJson = todos.map((t) => t.toJson()).toList();
        exportData['data']['todos'] = todosJson;
      }

      if (type.contains('note')) {
        final notes = ref.read(notesProvider);
        exportData['data']['notes'] = notes.map((n) => n.toMap()).toList();
      }

      if (type.contains('expense')) {
        final expenses = ref.read(expenseProvider);
        exportData['data']['expenses'] = expenses.map((e) {
          return {
            'id': e.id,
            'title': e.title,
            'amount': e.amount,
            'date': e.date.toIso8601String(),
            'category': e.category,
            'isIncome': e.isIncome,
          };
        }).toList();
      }

      final jsonString = DataExporter.prettyEncode(exportData);
      
      await Share.share(
        jsonString,
        subject: 'OmniPro Backup - ${DateTime.now().toString().split(' ').first}',
      );

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('$type exported successfully')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Import functionality',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To import data, paste your JSON backup content below.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• All data is stored locally on your device'),
            SizedBox(height: 8),
            Text('• No data is sent to any server'),
            SizedBox(height: 8),
            Text('• No account required'),
            SizedBox(height: 8),
            Text('• You can export your data anytime'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? Your data will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(todoProvider.notifier).state = [];
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
