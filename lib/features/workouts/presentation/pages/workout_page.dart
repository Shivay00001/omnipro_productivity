import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/features/workouts/presentation/providers/workout_provider.dart';
import 'package:uuid/uuid.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return ListTile(
            title: Text(workout.exercise),
            subtitle: Text('${workout.sets} sets x ${workout.reps} reps | ${workout.weight}kg'),
            trailing: Text(workout.date.toString().split(' ').first),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.fitness_center),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final ex = TextEditingController();
    final sets = TextEditingController();
    final reps = TextEditingController();
    final weight = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ex, decoration: const InputDecoration(labelText: 'Exercise')),
            Row(
              children: [
                Expanded(child: TextField(controller: sets, decoration: const InputDecoration(labelText: 'Sets'), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: reps, decoration: const InputDecoration(labelText: 'Reps'), keyboardType: TextInputType.number)),
              ],
            ),
            TextField(controller: weight, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ex.text.isNotEmpty) {
                ref.read(workoutProvider.notifier).logWorkout(Workout(
                  id: const Uuid().v4(),
                  exercise: ex.text,
                  sets: int.tryParse(sets.text) ?? 0,
                  reps: int.tryParse(reps.text) ?? 0,
                  weight: double.tryParse(weight.text) ?? 0,
                  date: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }
}
