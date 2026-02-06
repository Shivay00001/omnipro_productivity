import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/health/presentation/providers/health_provider.dart';

class HealthPage extends ConsumerWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(healthProvider);
    final weightController = TextEditingController();
    final heightController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Weight & Health')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: heightController, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text) ?? 0;
                if (weight > 0) {
                  ref.read(healthProvider.notifier).addWeight(weight);
                }
              },
              child: const Text('Log Weight'),
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return ListTile(
                    title: Text('${entry.weight} kg'),
                    subtitle: Text(entry.date.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
