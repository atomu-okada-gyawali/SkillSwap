import 'package:flutter/material.dart';
import 'package:skillswap/Widgets/custom_field_text.dart';
import 'package:skillswap/features/auth/presentation/widgets/or_divider.dart';
import 'package:skillswap/features/auth/presentation/widgets/purple_button.dart';
import 'package:skillswap/features/auth/presentation/widgets/social_button.dart';
import 'package:skillswap/features/dashboard/presentation/pages/home_screen.dart';
import 'package:skillswap/utils/my_colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    //login logic eta
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          label: 'Your Email',
          hint: 'Email',
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        CustomTextFormField(
          label: 'Password',
          hint: '••••••••••',
          obscureText: true,
          controller: _passwordController,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: null,
            child: Text(
              'Forgot password?',
              style: TextStyle(color: MyColors.color4, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _handleLogin,
          child: PurpleButton(
            text: "Continue",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 25),
        const OrDivider(),
        const SizedBox(height: 25),
        const SocialButton(text: 'Login with Apple', icon: Icons.apple),
        const SizedBox(height: 15),
        const SocialButton(
          text: 'Login with Google',
          icon: Icons.g_mobiledata,
          isGoogle: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
