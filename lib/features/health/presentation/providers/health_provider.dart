import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/prefs_service.dart';

class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {'weight': weight, 'date': date.toIso8601String()};
  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    weight: json['weight'],
    date: DateTime.parse(json['date']),
  );
}

final healthProvider = StateNotifierProvider<HealthNotifier, List<WeightEntry>>((ref) {
  return HealthNotifier();
});

class HealthNotifier extends StateNotifier<List<WeightEntry>> {
  HealthNotifier() : super([]) {
    _loadData();
  }

  final _prefs = PrefsService();

  void _loadData() {
    final data = _prefs.getString('weight_history');
    if (data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      state = decoded.map((e) => WeightEntry.fromJson(e)).toList();
    }
  }

  Future<void> addWeight(double weight) async {
    final entry = WeightEntry(weight: weight, date: DateTime.now());
    state = [...state, entry];
    await _prefs.setString('weight_history', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  double calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}
