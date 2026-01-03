import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/splash/presentation/pages/splash_screen.dart';
import 'package:skillswap/app/themes/default_theme_data.dart';
import 'package:skillswap/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage before the app starts
  try {
    final hiveService = HiveService();
    await hiveService.init();
    await hiveService.openBoxes();
  } catch (e) {
    // ignore: avoid_print
    print('Failed to initialize hive: $e');
  }

  runApp(
    ProviderScope(
      child: MaterialApp(
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // <- use your theme here
      ),
    ),
  );
}
