import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
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

  UserDataSourceImpl();

  @override
  Future<void> registerUser(String email, String password, String name) async {
    final hashedPassword = _hashPassword(password);

    final user = UserModel(
      id: const Uuid().v4(),
      email: email,
      name: name,
      passwordHash: hashedPassword,
    );

    final snapshot =
        await usersCollection.where('email', isEqualTo: email).get();

    if (snapshot.docs.isNotEmpty) {
      throw AuthException(
          'User already registered. Try another email or login');
    }

    await usersCollection.add(user.toMap());
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
      final snapshot =
          await usersCollection.where('email', isEqualTo: email).get();

      if (snapshot.docs.isEmpty) {
        await _logLoginAttempt(attempt);
        throw AuthException(
            'User not registered. Try another email or sign up');
      }

      final userDoc = snapshot.docs.first;
      final data = userDoc.data();
      final passwordHash = data['passwordHash'] as String;

      if (!_verifyPassword(password, passwordHash)) {
        await _logLoginAttempt(attempt);
        throw AuthException('Wrong credentials. Please try again');
      }

      attempt = attempt.copyWith(success: true);
      await _logLoginAttempt(attempt);

      return UserModel.fromMap(data);
    } catch (e) {
      rethrow;
    }
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
          passwordHash: '',
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

  String _hashPassword(String password) {
    return Crypt.sha256(password, salt: 'random_salt').toString();
  }

  bool _verifyPassword(String password, String hash) {
    return Crypt(hash).match(password);
  }
}
