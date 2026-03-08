import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:skillswap/features/posts/presentation/pages/my_posts_screen.dart';
import 'package:skillswap/features/splash/presentation/pages/splash_screen.dart';
import 'package:skillswap/utils/my_colors.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final serverImageName =
        user?.profilePicture ??
        authState.uploadPhotoName ??
        ref.read(userSessionServiceProvider).getCurrentUserProfilePicture();

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          spacing: 38,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: MyColors.color5,
              ),
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              foregroundColor: MyColors.color1,
                              radius: 45,
                              foregroundImage:
                                  (serverImageName != null &&
                                      serverImageName.isNotEmpty)
                                  ? NetworkImage(
                                      '${ApiEndpoints.baseUrl}$serverImageName',
                                    )
                                  : AssetImage(
                                      'assets/images/default-profile.jpg',
                                    ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    final user = ref
                                        .read(authViewModelProvider)
                                        .authEntity;
                                    if (user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(user: user),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: MyColors.color1,
                                    ),

                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        user?.fullName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 20,
                          color: MyColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Column(
                    spacing: 7,
                    children: [
                      MyBox(icon: Icons.mail, text: user?.email ?? 'No email'),
                      MyBox(
                        icon: Icons.person,
                        text: '@${user?.username ?? 'unknown'}',
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),

                  // My Posts Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MyColors.color5.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MyColors.color5.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Posts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: MyColors.color1,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyPostsScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: MyColors.color1,
                              ),
                              label: Text(
                                'View All',
                                style: TextStyle(
                                  color: MyColors.color1,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage and edit your skill posts',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  MyBox(
                    icon: Icons.logout,
                    text: "Logout",
                    color: Colors.red,
                    onTap: () async {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const SplashScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback? onTap;
  const MyBox({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? Colors.white;
    final fgColor = color == null ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: MyColors.secondaryTextColor.withOpacity(0.2),
              offset: Offset(0, 5),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
          color: bgColor,
          border: Border.all(color: MyColors.secondaryTextColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: fgColor),
            SizedBox(width: 10),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 15, color: fgColor)),
            ),
          ],
        ),
      ),
    );
  }
}
