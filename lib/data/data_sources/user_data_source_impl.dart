import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:password_project/data/data_sources/user_data_source.dart';
import 'package:password_project/data/model/login_attempt.dart';
import 'package:password_project/data/model/user.dart';
import 'package:password_project/domain/exceptions/auth_excpetions.dart';
import 'package:uuid/uuid.dart';

class UserDataSourceImpl extends UserDataSource {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final loginAttempts = FirebaseFirestore.instance.collection('loginAttempts');
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://secure-project-api.onrender.com',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  UserDataSourceImpl();

  @override
  Future<void> registerUser(String email, String password, String name) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        log('User registered successfully: ${response.data['userId']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 400:
            throw AuthException('The user already exists');
          case 500:
            throw AuthException(
                'Error during registration: ${e.response?.data['msg']}');
          default:
            throw AuthException('Unexpected error: ${e.response?.data['msg']}');
        }
      } else {
        throw AuthException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<UserModel?> loginUser(String email, String password) async {
    final recentAttempts = await FirebaseFirestore.instance
        .collection('loginAttempts')
        .where('email', isEqualTo: email)
        .where('timestamp',
            isGreaterThan: DateTime.now()
                .subtract(const Duration(minutes: 30))
                .toIso8601String())
        .where('success', isEqualTo: false)
        .get();

    if (recentAttempts.docs.length >= 5) {
      throw AuthException('Too many failed attempts. Please try again later.');
    }

    LoginAttempt attempt = LoginAttempt(
      id: const Uuid().v4(),
      email: email,
      timestamp: DateTime.now(),
      success: false,
    );

    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final user = response.data['user'];
        if (response.data['user'] == null) {
          throw AuthException('Invalid response from server');
        }

        attempt = attempt.copyWith(success: true);
        await _logLoginAttempt(attempt);
        return UserModel.fromMap(user);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        await _logLoginAttempt(attempt);
        switch (e.response?.statusCode) {
          case 401:
            throw AuthException('Invalid email or password');
          case 403:
            throw AuthException('Please verify your email before logging in');
          case 404:
            throw AuthException('User not found');
          default:
            throw AuthException('Unexpected error: ${e.response?.data['msg']}');
        }
      } else {
        await _logLoginAttempt(attempt);
        throw AuthException('Network error: ${e.message}');
      }
    }
    return null;
  }

  Future<void> _logLoginAttempt(LoginAttempt attempt) async {
    await loginAttempts.add(attempt.toMap());
  }

  @override
  Future<UserModel?> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Failed to sign in with Google');
      }

      final snapshot =
          await usersCollection.where('email', isEqualTo: user.email).get();

      if (snapshot.docs.isEmpty) {
        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? 'Anonymous',
        );

        await usersCollection.doc(user.uid).set(newUser.toMap());
        return newUser;
      }

      final userDoc = snapshot.docs.first;
      return UserModel.fromMap(userDoc.data());
    } catch (e) {
      throw AuthException('Google Sign-In failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendActivationLink(String email) async {
    try {
      final response = await _dio.post('/send-activation-link', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        log('Activation link sent successfully');
      } else {
        throw AuthException('Unexpected error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('DioException occurred: ${e.message}');
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 400:
            throw AuthException('Email is required');
          case 500:
            throw AuthException(
                'Error processing request: ${e.response?.data['message']}');
          default:
            throw AuthException(
                'Unexpected error: ${e.response?.data['message']}');
        }
      } else {
        throw AuthException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<void> sendPasswordResetLink(String email) async {
    try {
      final response = await _dio.post('/send-password-reset-link', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        log('Password reset link sent successfully');
      } else {
        throw AuthException('Unexpected error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('DioException occurred: ${e.message}');
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 404:
            throw AuthException('User not found');
          case 500:
            throw AuthException(
                'Error processing request: ${e.response?.data['message']}');
          default:
            throw AuthException(
                'Unexpected error: ${e.response?.data['message']}');
        }
      } else {
        throw AuthException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post(
        '/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        log('Password reset successful: ${response.data['message']}');
      } else {
        throw AuthException(
            'Unexpected error: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 400:
            throw AuthException(
                e.response?.data['message'] ?? 'Invalid request');
          case 404:
            throw AuthException('User not found');
          case 500:
            throw AuthException(
                'Error processing request: ${e.response?.data['message']}');
          default:
            throw AuthException(
                'Unexpected error: ${e.response?.data['message']}');
        }
      } else {
        throw AuthException('Network error: ${e.message}');
      }
    }
  }
}
