import 'package:flutter/material.dart';
import 'package:skillswap/features/splash/presentation/pages/splash_screen.dart';
import 'package:skillswap/app/themes/default_theme_data.dart';

void main() {
  runApp(
    MaterialApp(
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // <- use your theme here
    ),
  );
}
