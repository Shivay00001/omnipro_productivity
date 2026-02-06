import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:omnipro_productivity/core/providers/auth_provider.dart';

class PrefsService {
  static final PrefsService _instance = PrefsService._internal();
  factory PrefsService() => _instance;
  PrefsService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  static const String _authStateKey = 'auth_state';
  static const String _usersKey = 'users';
  static const String _currentUserIdKey = 'current_user_id';

  Future<AuthState?> getAuthState() async {
    final json = _prefs.getString(_authStateKey);
    if (json == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(json);
      return AuthState.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAuthState(AuthState state) async {
    await _prefs.setString(_authStateKey, jsonEncode(state.toMap()));
  }

  Future<void> clearAuthState() async {
    await _prefs.remove(_authStateKey);
    await _prefs.remove(_currentUserIdKey);
  }

  Future<void> saveUser(String userId, String username, String email, String passwordHash) async {
    final users = await getAllUsers();
    users[userId] = {
      'userId': userId,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_usersKey, jsonEncode(users));
    await _prefs.setString(_currentUserIdKey, userId);
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    final json = _prefs.getString(_usersKey);
    if (json == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(json));
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    for (final user in users.values) {
      if (user['email'] == email) {
        return user as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final users = await getAllUsers();
    return users[userId] as Map<String, dynamic>?;
  }

  Future<void> updatePassword(String userId, String newHash) async {
    final users = await getAllUsers();
    if (users.containsKey(userId)) {
      users[userId]['passwordHash'] = newHash;
      await _prefs.setString(_usersKey, jsonEncode(users));
    }
  }

  Future<void> updateProfile(String userId, {String? username, String? email}) async {
    final users = await getAllUsers();
    if (users.containsKey(userId)) {
      if (username != null) users[userId]['username'] = username;
      if (email != null) users[userId]['email'] = email;
      await _prefs.setString(_usersKey, jsonEncode(users));
    }
  }

  String? getCurrentUserId() {
    return _prefs.getString(_currentUserIdKey);
  }

  Future<void> setCurrentUserId(String userId) async {
    await _prefs.setString(_currentUserIdKey, userId);
  }

  Future<bool> userExists(String email) async {
    return await getUserByEmail(email) != null;
  }
}
