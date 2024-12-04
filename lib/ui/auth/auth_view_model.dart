import 'dart:developer';

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
      log('Unexpected error occurred: $e');

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

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      _currentUser = await userDataSource.googleSignIn();
      if (_currentUser != null) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Google Sign-In was canceled by the user.';
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during Google Sign-In.';
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> sendActivationLink(String email) async {
    _setLoading(true);
    try {
      await userDataSource.sendActivationLink(email);
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      log('AuthException occurred: ${e.message}');
    } catch (e, stackTrace) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      log('Unexpected error: $e\n$stackTrace');
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
