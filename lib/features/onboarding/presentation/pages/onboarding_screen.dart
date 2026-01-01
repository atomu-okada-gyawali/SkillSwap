import 'package:flutter/material.dart';
import 'package:skillswap/Widgets/onboarding_page.dart';
import 'package:skillswap/features/auth/presentation/widgets/purple_button.dart';
import 'package:skillswap/features/auth/presentation/pages/auth_screen.dart';
import 'package:skillswap/utils/my_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                children: [
                  OnboardPage(
                    image: "assets/images/onboard1.svg",
                    title: "Discover & Exchange Skills",
                    description:
                        "Learn and teach without spending money. Explore and find the perfect match.",
                  ),
                  OnboardPage(
                    image: "assets/images/onboard2.svg",
                    title: "Barter & Communicate Easily",
                    description:
                        "Send proposals, negotiate via chat, and exchange skills fairly.",
                  ),
                  OnboardPage(
                    image: "assets/images/onboard3.svg",
                    title: "Schedule & Stay Updated",
                    description:
                        "Plan sessions with clarity and get notifications instantly.",
                  ),
                ],
              ),
            ),

            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: ExpandingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: MyColors.color4,
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PurpleButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
