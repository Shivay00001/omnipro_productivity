import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/providers/auth_provider.dart';
import 'package:omnipro_productivity/core/widgets/login_screen.dart';
import 'package:omnipro_productivity/core/widgets/splash_screen.dart';
import 'package:omnipro_productivity/core/widgets/app_lock_wrapper.dart';
import 'package:omnipro_productivity/features/dashboard/presentation/pages/dashboard_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isLoggedIn) {
      return const LoginScreen();
    }

    return const ModernSplashScreen(child: AppLockWrapper(child: DashboardPage()));
  }
}

class AuthGuard extends ConsumerWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isLoggedIn) {
      return const LoginScreen();
    }

    return child;
  }
}
