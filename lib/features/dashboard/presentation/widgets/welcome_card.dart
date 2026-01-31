import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/utils/my_colors.dart';

class WelcomeCard extends ConsumerStatefulWidget {
  const WelcomeCard({super.key});

  @override
  ConsumerState<WelcomeCard> createState() => _WelcomeCardConsumerState();
}

class _WelcomeCardConsumerState extends ConsumerState<WelcomeCard> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final serverImageName =
        authState.authEntity?.profilePicture ??
        authState.uploadPhotoName ??
        ref.read(userSessionServiceProvider).getCurrentUserProfilePicture();

    final ImageProvider<Object> profileImage =
        (serverImageName != null && serverImageName.isNotEmpty)
        ? NetworkImage(
            '${ApiEndpoints.baseUrl}auth/profile-image/$serverImageName',
          )
        : const AssetImage('assets/images/default-profile.jpg');

    return Card(
      color: MyColors.color4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "Hello Ramesh",
                    style: const TextStyle(
                      fontSize: 20,
                      color: MyColors.color1,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  height: 30,
                  width: 30,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: MyColors.color1,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                CircleAvatar(radius: 15, backgroundImage: profileImage),
              ],
            ),
            const SizedBox(height: 15),
            SearchBar(hintText: "Search skills..."),
          ],
        ),
      ),
    );
  }
}
