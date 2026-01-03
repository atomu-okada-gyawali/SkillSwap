import 'package:flutter/material.dart';
import 'package:skillswap/features/auth/presentation/widgets/login_form.dart';
import 'package:skillswap/features/auth/presentation/widgets/sign_up_form.dart';
import 'package:skillswap/utils/my_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginActive = true),
                        child: Column(
                          children: [
                            Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLoginActive
                                    ? MyColors.color4
                                    : MyColors.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isLoginActive)
                              Container(
                                height: 3,
                                color: MyColors.color4,
                                width: 60,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginActive = false),
                        child: Column(
                          children: [
                            Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLoginActive
                                    ? MyColors.secondaryTextColor
                                    : MyColors.color4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!isLoginActive)
                              Container(
                                height: 3,
                                color: MyColors.color4,
                                width: 60,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Image.asset('assets/icons/branding.png', width: 200),
                const SizedBox(height: 40),
                Expanded(
                  child: isLoginActive
                      ? LoginForm()
                      : SignUpForm(
                          onRegistered: () =>
                              setState(() => isLoginActive = true),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
