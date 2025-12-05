import 'package:flutter/material.dart';
import 'package:skillswap/utils/my_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: MyColors.color4,
      ),
      body: const Center(child: Text('Welcome to the Home Screen!')),
    );
  }
}
