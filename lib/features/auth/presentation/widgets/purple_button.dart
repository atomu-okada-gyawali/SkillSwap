import 'package:flutter/material.dart';
import 'package:skillswap/utils/my_colors.dart';

class PurpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PurpleButton({required this.text, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.color4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          shadowColor: MyColors.color4.withAlpha(77),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
