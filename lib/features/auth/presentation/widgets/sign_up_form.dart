import 'package:flutter/material.dart';
import 'package:skillswap/Widgets/custom_field_text.dart';
import 'package:skillswap/features/auth/presentation/widgets/purple_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _handleSignUp() {
    
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          label: 'Username',
          hint: 'Username',
          controller: _usernameController,
        ),
        const SizedBox(height: 20),
        CustomTextFormField(
          label: 'Password',
          hint: '••••••••••',
          obscureText: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        CustomTextFormField(
          label: 'Confirm Password',
          hint: '••••••••••',
          obscureText: true,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: _handleSignUp,
          child: const PurpleButton(text: 'Sign Up'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
