import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/time_tracker/data/models/time_model.dart';
import 'package:uuid/uuid.dart';

final timeProvider = StateNotifierProvider<TimeNotifier, List<TimeSession>>((ref) {
  return TimeNotifier();
});

class TimeNotifier extends StateNotifier<List<TimeSession>> {
  TimeNotifier() : super([]) {
    _loadSessions();
  }

  final _box = HiveService().getBox('timers');
  TimeSession? activeSession;

  void _loadSessions() {
    state = _box.values.cast<TimeSession>().toList();
  }

  Future<void> startSession(String projectName) async {
    activeSession = TimeSession(
      id: const Uuid().v4(),
      projectName: projectName,
      startTime: DateTime.now(),
    );
    notifyListeners(); // Manual notify if necessary or use state
  }

  Future<void> stopSession() async {
    if (activeSession != null) {
      activeSession!.endTime = DateTime.now();
      await _box.put(activeSession!.id, activeSession!);
      state = [...state, activeSession!];
      activeSession = null;
    }
  }
  
  void notifyListeners() {
    state = [...state];
  }
}
