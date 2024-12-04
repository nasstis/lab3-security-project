import 'package:password_project/data/model/user.dart';

abstract class UserDataSource {
  Future<void> registerUser(String email, String password, String name);
  Future<UserModel?> loginUser(String email, String password);
  Future<UserModel?> googleSignIn();
  Future<void> sendActivationLink(String email);
  Future<void> sendPasswordResetLink(String email);
}
