import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookkeeping_app/app/app.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/local_preferences_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsRepo = LocalPreferencesRepository(sharedPrefs);

  runApp(
    ProviderScope(
      overrides: [preferencesRepositoryProvider.overrideWithValue(prefsRepo)],
      child: const BookkeepingApp(),
    ),
  );
}
