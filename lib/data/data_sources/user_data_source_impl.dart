import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
import 'package:password_project/data/data_sources/user_data_source.dart';
import 'package:password_project/data/model/user.dart';
import 'package:password_project/domain/exceptions/auth_excpetions.dart';
import 'package:uuid/uuid.dart';

class UserDataSourceImpl extends UserDataSource {
  final FirebaseFirestore firestore;

  UserDataSourceImpl({required this.firestore});

  @override
  Future<void> registerUser(String email, String password, String name) async {
    final hashedPassword = _hashPassword(password);

    final user = UserModel(
      id: const Uuid().v4(),
      email: email,
      name: name,
      passwordHash: hashedPassword,
    );

    await firestore.collection('users').add(user.toMap());
  }

  @override
  Future<UserModel?> loginUser(String email, String password) async {
    final snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isEmpty) {
      throw AuthException('User not registered.');
    }

    final userDoc = snapshot.docs.first;
    final data = userDoc.data();
    final passwordHash = data['passwordHash'] as String;

    if (!_verifyPassword(password, passwordHash)) {
      throw AuthException('Incorrect password.');
    }

    return UserModel.fromMap(data);
  }

  String _hashPassword(String password) {
    return Crypt.sha256(password, salt: 'random_salt').toString();
  }

  bool _verifyPassword(String password, String hash) {
    return Crypt(hash).match(password);
  }
}