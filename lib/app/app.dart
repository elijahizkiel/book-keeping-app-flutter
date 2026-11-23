import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/app/router.dart';
import 'package:bookkeeping_app/app/theme/app_theme.dart';
import 'package:bookkeeping_app/domain/entities/user_preferences.dart';

class BookkeepingApp extends ConsumerWidget {
  const BookkeepingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(preferencesStateProvider);

    ThemeMode themeMode;
    switch (prefs.themePreference) {
      case AppThemePreference.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemePreference.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppThemePreference.system:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp.router(
      title: 'BookKeeping',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
