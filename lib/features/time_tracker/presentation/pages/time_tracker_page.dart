import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/time_tracker/presentation/providers/time_provider.dart';
import 'package:intl/intl.dart';

class TimeTrackerPage extends ConsumerWidget {
  const TimeTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(timeProvider);
    final notifier = ref.read(timeProvider.notifier);
    final activeSession = notifier.activeSession;

    return Scaffold(
      appBar: AppBar(title: const Text('Time Tracker')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (activeSession != null) ...[
                  Text('Tracking: ${activeSession.projectName}', style: const TextStyle(fontSize: 20)),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, _) => Text(
                      activeSession.duration.toString().split('.').first,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => notifier.stopSession(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Stop'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => _showStartDialog(context, notifier),
                    child: const Text('Start New Session'),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[sessions.length - 1 - index];
                return ListTile(
                  title: Text(session.projectName),
                  subtitle: Text('${DateFormat.yMMMd().format(session.startTime)} | ${session.duration.toString().split('.').first}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStartDialog(BuildContext context, TimeNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Name'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Work, Study, etc.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                notifier.startSession(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
