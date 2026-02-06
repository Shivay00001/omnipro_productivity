import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/secure_storage_service.dart';
import 'package:omnipro_productivity/features/passwords/data/models/password_model.dart';
import 'package:uuid/uuid.dart';

final passwordProvider = StateNotifierProvider<PasswordNotifier, List<PasswordEntry>>((ref) {
  return PasswordNotifier();
});

class PasswordNotifier extends StateNotifier<List<PasswordEntry>> {
  PasswordNotifier() : super([]) {
    _loadPasswords();
  }

  final _secureStorage = SecureStorageService();

  Future<void> _loadPasswords() async {
    final data = await _secureStorage.read('passwords_list');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      state = decoded.map((e) => PasswordEntry.fromJson(e)).toList();
    }
  }

  Future<void> savePassword(PasswordEntry entry) async {
    state = [...state, entry];
    await _secureStorage.write('passwords_list', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> deletePassword(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _secureStorage.write('passwords_list', jsonEncode(state.map((e) => e.toJson()).toList()));
  }
}
