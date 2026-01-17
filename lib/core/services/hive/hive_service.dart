import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:path_provider/path_provider.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  //init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  //Register Adapters
  void _registerAdapter() {
    //Register other adapters here
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  //Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  //Close boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }
  //Queries

  //====================Auth Queries====================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }
}
