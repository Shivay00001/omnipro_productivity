import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/alarm/presentation/providers/alarm_provider.dart';
import 'package:omnipro_productivity/features/alarm/presentation/providers/wallet_provider.dart';
import 'package:intl/intl.dart';

class ExtremeAlarmPage extends ConsumerWidget {
  const ExtremeAlarmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);
    final walletBalance = ref.watch(walletProvider);
    final notifier = ref.read(alarmProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Extreme Alarm')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wallet Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${walletBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showTopUpDialog(context, ref),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Top Up'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return ListTile(
                  title: Text(DateFormat.jm().format(alarm.alarmTime), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  subtitle: Text('Penalty: \$${alarm.penaltyPerMinute}/min | Stake: \$${alarm.stakeAmount}'),
                  trailing: Switch(
                    value: alarm.isActive,
                    onChanged: (val) {
                      alarm.isActive = val;
                      alarm.save();
                      ref.invalidate(alarmProvider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimeDialog(context, ref),
        backgroundColor: Colors.red,
        child: const Icon(Icons.alarm_add, color: Colors.white),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top Up Wallet'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount (\$)', hintText: 'Enter amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              if (amount > 0) {
                ref.read(walletProvider.notifier).topUp(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Pay with Razorpay'),
          ),
        ],
      ),
    );
  }

  void _showAddTimeDialog(BuildContext context, WidgetRef ref) async {
// ...
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final now = DateTime.now();
      final alarmTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      ref.read(alarmProvider.notifier).addAlarm(alarmTime);
    }
  }
}
