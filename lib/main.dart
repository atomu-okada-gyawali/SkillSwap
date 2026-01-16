import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillswap/app.dart';
import 'package:skillswap/core/services/hive/hive_service.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  try {
    final hiveService = HiveService();
    await hiveService.init();
    await hiveService.openBoxes();
  } catch (e) {
    // ignore: avoid_print
    print('Failed to initialize hive: $e');
  }

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: MyApp(),
    ),
  );
}
