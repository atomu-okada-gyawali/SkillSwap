import 'package:flutter/material.dart';
import 'package:skillswap/app/themes/default_theme_data.dart';
import 'package:skillswap/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:skillswap/features/splash/presentation/pages/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // <- use your theme here
    );
  }
}
