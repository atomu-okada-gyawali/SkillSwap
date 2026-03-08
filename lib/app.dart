import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:skillswap/app/themes/default_theme_data.dart';
import 'package:skillswap/features/splash/presentation/pages/splash_screen.dart';
// import 'package:skillswap/lib/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'features/auth/presentation/view_model/auth_viewmodel.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool isDialogOpen = false;
  StreamSubscription? _accelerometerSub;
  final double shakeThreshold = 15;

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    _accelerometerSub = accelerometerEvents.listen((event) {
      double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

if (acceleration > shakeThreshold && !isDialogOpen) {
  _handleShake();
}
    });
  }

  void _handleShake() {
    final context = navigatorKey.currentContext;

    if (context == null || isDialogOpen) return;

    isDialogOpen = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Shake detected. Logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              isDialogOpen = false;
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await ref.read(authViewModelProvider.notifier).logout();

              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );

              isDialogOpen = false;
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
