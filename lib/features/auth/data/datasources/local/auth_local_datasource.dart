import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skillswap/core/services/hive/hive_service.dart';
import 'package:skillswap/features/auth/data/datasources/remote/auth_datasource.dart';

import 'package:skillswap/features/auth/data/models/auth_hive_model.dart';

//Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  bool isEmailExists(String email) {
    try {
      return _hiveService.isEmailExists(email);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    final user = await _hiveService.loginUser(email, password);
    if (user != null) return user;
    throw Exception('Invalid credentials');
  }

  @override
  Future<AuthHiveModel> getCurrentUser(String authId) async {
    final user = _hiveService.getCurrentUser(authId);
    if (user != null) return user;
    throw Exception('User not found');
  }
}
