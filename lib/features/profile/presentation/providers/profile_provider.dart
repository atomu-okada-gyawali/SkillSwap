import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/profile/data/repositories/profile_repository.dart';
import 'package:skillswap/core/api/api_client.dart';
import 'package:skillswap/core/services/storage/token_service.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, AuthEntity?>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<AuthEntity?> {
  @override
  Future<AuthEntity?> build() async {
    return _fetchProfile();
  }

  Future<AuthEntity?> _fetchProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProfile();
    return result.fold((failure) => null, (user) => user);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }

  Future<bool> updateProfile({String? fullName, String? username}) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updateProfile(
      fullName: fullName,
      username: username,
    );

    return result.fold((failure) => false, (user) {
      state = AsyncValue.data(user);
      return true;
    });
  }

  Future<bool> uploadProfilePicture(File image) async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.uploadProfilePicture(image);

    return result.fold((failure) => false, (imageName) {
      ref.invalidate(profileProvider);
      return true;
    });
  }
}
