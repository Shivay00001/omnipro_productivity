import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/prefs_service.dart';
import 'package:uuid/uuid.dart';

class AuthState {
  final String? userId;
  final String? username;
  final String? email;
  final bool isLoggedIn;
  final bool isFirstTimeUser;
  final bool useBiometrics;
  final DateTime? lastLogin;

  AuthState({
    this.userId,
    this.username,
    this.email,
    this.isLoggedIn = false,
    this.isFirstTimeUser = true,
    this.useBiometrics = false,
    this.lastLogin,
  });

  AuthState copyWith({
    String? userId,
    String? username,
    String? email,
    bool? isLoggedIn,
    bool? isFirstTimeUser,
    bool? useBiometrics,
    DateTime? lastLogin,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'isLoggedIn': isLoggedIn,
      'isFirstTimeUser': isFirstTimeUser,
      'useBiometrics': useBiometrics,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory AuthState.fromMap(Map<String, dynamic> map) {
    return AuthState(
      userId: map['userId'] as String?,
      username: map['username'] as String?,
      email: map['email'] as String?,
      isLoggedIn: map['isLoggedIn'] as bool? ?? false,
      isFirstTimeUser: map['isFirstTimeUser'] as bool? ?? true,
      useBiometrics: map['useBiometrics'] as bool? ?? false,
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final PrefsService _prefs = PrefsService();

  AuthNotifier() : super(AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final savedState = await _prefs.getAuthState();
    if (savedState != null) {
      state = savedState;
    }
  }

  Future<void> register(String username, String email, String password) async {
    final userId = const Uuid().v4();
    final hashedPassword = _hashPassword(password);
    
    await _prefs.saveUser(userId, username, email, hashedPassword);
    
    state = AuthState(
      userId: userId,
      username: username,
      email: email,
      isLoggedIn: true,
      isFirstTimeUser: false,
      useBiometrics: false,
      lastLogin: DateTime.now(),
    );
    
    await _prefs.saveAuthState(state);
  }

  Future<bool> login(String email, String password) async {
    final userData = await _prefs.getUserByEmail(email);
    
    if (userData == null) return false;
    
    final hashedInput = _hashPassword(password);
    if (userData['passwordHash'] != hashedInput) return false;
    
    state = AuthState(
      userId: userData['userId'] as String,
      username: userData['username'] as String,
      email: email,
      isLoggedIn: true,
      isFirstTimeUser: false,
      useBiometrics: state.useBiometrics,
      lastLogin: DateTime.now(),
    );
    
    await _prefs.saveAuthState(state);
    return true;
  }

  Future<void> logout() async {
    await _prefs.clearAuthState();
    state = AuthState();
  }

  Future<void> enableBiometrics(bool enabled) async {
    state = state.copyWith(useBiometrics: enabled);
    await _prefs.saveAuthState(state);
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (state.userId == null) return false;
    
    final userData = await _prefs.getUserById(state.userId!);
    if (userData == null || userData['passwordHash'] != _hashPassword(currentPassword)) {
      return false;
    }
    
    final newHashed = _hashPassword(newPassword);
    await _prefs.updatePassword(state.userId!, newHashed);
    return true;
  }

  Future<void> updateProfile({String? username, String? email}) async {
    if (state.userId == null) return;
    
    await _prefs.updateProfile(state.userId!, username: username, email: email);
    
    state = state.copyWith(
      username: username ?? state.username,
      email: email ?? state.email,
    );
    
    await _prefs.saveAuthState(state);
  }

  String _hashPassword(String password) {
    // Simple hash for demo - use crypto package in production
    int hash = 0;
    for (int i = 0; i < password.length; i++) {
      hash = ((hash << 5) - hash) + password.codeUnitAt(i);
      hash = hash & hash;
    }
    return hash.toString();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final currentUserProvider = Provider<AuthState?>((ref) {
  return ref.watch(authProvider);
});
