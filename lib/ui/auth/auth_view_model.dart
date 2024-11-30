import 'package:flutter/foundation.dart';
import 'package:password_project/data/data_sources/user_data_source.dart';
import 'package:password_project/data/model/user.dart';
import 'package:password_project/domain/exceptions/auth_excpetions.dart';

class AuthViewModel extends ChangeNotifier {
  final UserDataSource userDataSource;

  AuthViewModel({required this.userDataSource});

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loginUser(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await userDataSource.loginUser(email, password);
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> registerUser(String email, String password, String name) async {
    _setLoading(true);
    try {
      await userDataSource.registerUser(email, password, name);
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  void logoutUser() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}