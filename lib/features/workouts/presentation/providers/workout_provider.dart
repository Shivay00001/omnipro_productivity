import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/prefs_service.dart';

class Workout {
  final String id;
  final String exercise;
  final int sets;
  final int reps;
  final double weight;
  final DateTime date;

  Workout({
    required this.id,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise': exercise,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'date': date.toIso8601String(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'],
    exercise: json['exercise'],
    sets: json['sets'],
    reps: json['reps'],
    weight: json['weight'],
    date: DateTime.parse(json['date']),
  );
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<Workout>>((ref) {
  return WorkoutNotifier();
});

class WorkoutNotifier extends StateNotifier<List<Workout>> {
  WorkoutNotifier() : super([]) { _loadWorkouts(); }
  final _prefs = PrefsService();

  void _loadWorkouts() {
    final data = _prefs.getString('workout_history');
    if (data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      state = decoded.map((e) => Workout.fromJson(e)).toList();
    }
  }

  Future<void> logWorkout(Workout workout) async {
    state = [...state, workout];
    await _prefs.setString('workout_history', jsonEncode(state.map((e) => e.toJson()).toList()));
  }
}
