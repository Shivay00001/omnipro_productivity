import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omnipro_productivity/features/alarm/presentation/pages/alarm_trigger_screen.dart';
import 'package:omnipro_productivity/features/alarm/presentation/providers/alarm_provider.dart';
import 'package:omnipro_productivity/core/providers/auth_provider.dart';

class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper> {
  bool _isAuthenticating = true;
  bool _isAuthenticated = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authState = ref.read(authProvider);
    
    if (!authState.useBiometrics) {
      setState(() {
        _isAuthenticating = false;
        _isAuthenticated = true;
      });
      return;
    }

    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      setState(() => _isAuthenticating = true);
      
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Unlock OmniPro Productivity',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      
      setState(() {
        _isAuthenticating = false;
        _isAuthenticated = authenticated;
      });
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final triggeredAlarm = ref.watch(alarmProvider.notifier).triggeredAlarm;
    
    if (triggeredAlarm != null) {
      return const AlarmTriggerScreen();
    }

    if (_isAuthenticating) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Authenticating...'),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.deepPurple[400],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'App Locked',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use biometrics or PIN to unlock',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() => _isAuthenticated = true);
                  },
                  child: const Text('Skip (requires biometric setting off)'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
