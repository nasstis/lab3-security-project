class UserModel {
  String id;
  String email;
  String name;
  String passwordHash;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: map['uid'] as String,
        email: map['email'] as String,
        name: map['name'] as String,
        passwordHash: map['passwordHash'] as String);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'name': name,
      'passwordHash': passwordHash,
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, firstName: $name}';
  }
}
