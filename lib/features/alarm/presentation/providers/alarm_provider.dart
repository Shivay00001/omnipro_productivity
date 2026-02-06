import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/features/alarm/data/models/extreme_alarm_model.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:omnipro_productivity/features/alarm/presentation/providers/wallet_provider.dart';

final alarmProvider = StateNotifierProvider<AlarmNotifier, List<ExtremeAlarm>>((ref) {
  return AlarmNotifier(ref);
});

class AlarmNotifier extends StateNotifier<List<ExtremeAlarm>> {
  final Ref ref;
  AlarmNotifier(this.ref) : super([]) {
    _loadAlarms();
    _startTimer();
  }

  final _box = HiveService().getBox('extreme_alarms');
  // Removed _walletBox as we use WalletNotifier
  final _player = AudioPlayer();
  Timer? _checkTimer;
  ExtremeAlarm? triggeredAlarm;
  DateTime? triggerTime;

  void _loadAlarms() {
    state = _box.values.cast<ExtremeAlarm>().toList();
  }

  void _startTimer() {
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      for (final alarm in state) {
        if (alarm.isActive && 
            now.hour == alarm.alarmTime.hour && 
            now.minute == alarm.alarmTime.minute &&
            triggeredAlarm == null) {
          _triggerAlarm(alarm);
        }
      }
    });
  }

  double get walletBalance => ref.read(walletProvider);

  Future<void> _triggerAlarm(ExtremeAlarm alarm) async {
    triggeredAlarm = alarm;
    triggerTime = DateTime.now();
    await _player.setReleaseMode(ReleaseMode.loop);
    // Note: In real production, you'd use a local asset. 
    // For this example, we assume a loud sound is available or use a default beep.
    await _player.play(UrlSource('https://www.soundjay.com/buttons/beep-01a.mp3')); 
    // In a real app, you would use a Navigator key to show the Alarm screen immediately.
    state = [...state]; 
  }

  Future<void> stopAlarm(String essay) async {
    if (triggeredAlarm == null) return;
    
    // Verify essay (simple word count for now)
    final words = essay.trim().split(RegExp(r'\s+')).length;
    if (words < triggeredAlarm!.minWordCount) {
      throw 'Essay too short! You need at least ${triggeredAlarm!.minWordCount} words.';
    }

    _player.stop();
    final delayMinutes = DateTime.now().difference(triggerTime!).inMinutes;
    final penalty = delayMinutes * triggeredAlarm!.penaltyPerMinute;

    if (penalty > 0) {
      ref.read(walletProvider.notifier).deduct(penalty);
    }

    triggeredAlarm!.isActive = false;
    await triggeredAlarm!.save();
    triggeredAlarm = null;
    triggerTime = null;
    _loadAlarms();
  }

  Future<void> addAlarm(DateTime time) async {
    final alarm = ExtremeAlarm.create(time: time);
    await _box.put(alarm.id, alarm);
    _loadAlarms();
  }
}
