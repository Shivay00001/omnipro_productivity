import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/alarm/presentation/providers/alarm_provider.dart';

class AlarmTriggerScreen extends ConsumerStatefulWidget {
  const AlarmTriggerScreen({super.key});

  @override
  ConsumerState<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends ConsumerState<AlarmTriggerScreen> {
  final _essayController = TextEditingController();
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final alarm = ref.watch(alarmProvider.notifier).triggeredAlarm;
    if (alarm == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'WAKE UP NOW!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Penalty accumulating: \$${ref.watch(alarmProvider.notifier).triggeredAlarm?.penaltyPerMinute}/min',
                style: const TextStyle(color: Colors.yellow, fontSize: 18),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Essay Topic: ${alarm.requiredEssayTopic}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('Minimum words: ${alarm.minWordCount}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextField(
                          controller: _essayController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Start writing...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_error, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
                  onPressed: () async {
                    try {
                      await ref.read(alarmProvider.notifier).stopAlarm(_essayController.text);
                    } catch (e) {
                      setState(() => _error = e.toString());
                    }
                  },
                  child: const Text('I AM AWAKE (VERIFY ESSAY)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
