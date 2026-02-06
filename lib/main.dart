import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/core/storage/sqlite_service.dart';
import 'package:omnipro_productivity/core/theme/app_theme.dart';
import 'package:omnipro_productivity/core/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await HiveService().init();
  await SQLiteService().init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightColorScheme, ColorScheme? darkColorScheme) {
        return MaterialApp(
          title: 'OmniPro Productivity',
          theme: AppTheme.lightTheme.copyWith(
            colorScheme: lightColorScheme?.harmonized() ?? AppTheme.lightTheme.colorScheme,
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            colorScheme: darkColorScheme?.harmonized() ?? AppTheme.darkTheme.colorScheme,
          ),
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.1),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
