import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/widgets/custom_field_text.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/auth/presentation/widgets/or_divider.dart';
import 'package:skillswap/features/auth/presentation/widgets/purple_button.dart';
import 'package:skillswap/features/auth/presentation/widgets/social_button.dart';
import 'package:skillswap/features/dashboard/presentation/pages/home_screen.dart';
import 'package:skillswap/utils/my_colors.dart';
//This is login form widget
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authViewModelProvider.notifier)
          .login(
            username: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage ?? 'An unknown error occurred',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            label: 'Your Email',
            hint: 'Email',
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            label: 'Password',
            hint: '••••••••••',
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
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
          PurpleButton(
            text: authState.status == AuthStatus.loading
                ? 'Loading...'
                : 'Continue',
            onPressed: authState.status == AuthStatus.loading
                ? null
                : _handleLogin,
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
      ),
    );
  }
}
