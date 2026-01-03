import 'package:skillswap/features/auth/data/models/auth_hive_model.dart';


abstract interface class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel> login(String email, String password);
  Future<AuthHiveModel> getCurrentUser(String authId);
  Future<bool> logout();

  //get email exists
 bool isEmailExists(String email);
}
